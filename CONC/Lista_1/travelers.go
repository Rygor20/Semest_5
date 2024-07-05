package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

var (
	m         int
	n         int
	k         int
	travelers []*Traveler
	grid      [][]int
	trails    [][]int
	semBoard  chan struct{}
	semPrint  chan struct{}
)

type Traveler struct {
	id int
	x  int
	y  int
}

func validateArg(arg string, name string) (int, error) {
	val, err := strconv.Atoi(arg)
	if err != nil {
		return 0, fmt.Errorf("Error: %s is not integer", name)
	}
	return val, nil
}

func createGrid(m, n int) [][]int {
	grid := make([][]int, m)
	for i := 0; i < m; i++ {
		grid[i] = make([]int, n)
	}
	return grid
}

// func printGrid(grid [][]int) {
// 	for i := 0; i < len(grid); i++ {
// 		for j := 0; j < len(grid[0]); j++ {
// 			fmt.Printf("%2d ", grid[i][j])
// 		}
// 		fmt.Println()
// 	}
// 	fmt.Println()
// }

func placeRandomNumber(k int) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	change := 1

	for change <= k {
		x := r.Intn(len(grid))
		y := r.Intn(len(grid[0]))

		// if change <= k {
		select {
		case semBoard <- struct{}{}:
			if grid[x][y] == 0 {
				grid[x][y] = change

				traveler := &Traveler{id: change, x: x, y: y}
				travelers = append(travelers, traveler)

				go moveTraveler(traveler)

				change++
			}
			<-semBoard
		default:
		}
		// } else {
		// 	break
		// }

		time.Sleep(2 * time.Second)
	}
}

func moveTraveler(traveler *Traveler) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for {
		if r.Intn(2) == 0 {
			possibleMoves := []struct{ dx, dy int }{{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
			move := possibleMoves[r.Intn(4)]

			newX := traveler.x + move.dx
			newY := traveler.y + move.dy

			if newX >= 0 && newX < len(grid) && newY >= 0 && newY < len(grid[0]) {
				select {
				case semBoard <- struct{}{}:
					semPrint <- struct{}{}
					if grid[newX][newY] == 0 {
						grid[traveler.x][traveler.y] = 0
						if newX == traveler.x {
							trails[traveler.x][traveler.y] = -1
						} else {
							trails[traveler.x][traveler.y] = -2
						}
						traveler.x = newX
						traveler.y = newY
						grid[newX][newY] = traveler.id
						trails[newX][newY] = traveler.id
					}
					<-semBoard
					<-semPrint
				default:
				}
			}
		}
		time.Sleep(time.Second)
	}
}

func cameraShot() {
	semBoard <- struct{}{}
	semPrint <- struct{}{}
	for i := 0; i < len(trails); i++ {
		for j := 0; j < len(trails[0]); j++ {
			if trails[i][j] == -2 {
				trails[i][j] = 0
				fmt.Printf("%2s ", "||")
			} else if trails[i][j] == -1 {
				trails[i][j] = 0
				fmt.Printf("%2s ", "==")
			} else if trails[i][j] == 0 {
				fmt.Printf("%2s ", "##")
			} else {
				if trails[i][j]-1 < 10 {
					fmt.Printf("%s%d ", "0", trails[i][j]-1)
				} else {
					fmt.Printf("%2d ", trails[i][j]-1)
				}
			}
		}
		fmt.Println()
	}
	fmt.Println()
	<-semBoard
	<-semPrint
}

// poprawić do drugiej listy, nie blokować całej planszy, rozwiązywać problemy "lokalnie"
func main() {
	if len(os.Args) != 4 {
		fmt.Println("Correct usage: go run test.go m n k")
		return
	}

	var err error
	if m, err = validateArg(os.Args[1], "m"); err != nil {
		fmt.Println(err)
		return
	}

	if n, err = validateArg(os.Args[2], "n"); err != nil {
		fmt.Println(err)
		return
	}

	if k, err = validateArg(os.Args[3], "k"); err != nil {
		fmt.Println(err)
		return
	}

	if k >= m*n {
		fmt.Println("Error: k doesn't meet requirement k < m*n")
		return
	}

	grid = createGrid(m, n)
	trails = createGrid(m, n)

	semBoard = make(chan struct{}, 1)
	semPrint = make(chan struct{}, 1)

	go placeRandomNumber(k)

	for {
		cameraShot()
		time.Sleep(4 * time.Second)
	}
}
