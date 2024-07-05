package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"sync"
	"time"
)

var (
	m             int
	n             int
	k             int
	board         Board
	wildTravelers WildTravelers
	camera        Camera
	waitGroup     sync.WaitGroup
)

const (
	probability = 0.85
	delay       = 1
)

func validateArg(arg string, name string) (int, error) {
	val, err := strconv.Atoi(arg)
	if err != nil {
		return 0, fmt.Errorf("Error: %s is not integer", name)
	}
	return val, nil
}

type Board struct {
	m     int
	n     int
	nodes [][]Node
}

type WildTravelers struct {
	m     int
	n     int
	wilds [][]WildTraveler
}

func (b *Board) Init(m, n int) {
	var nodes = make([][]Node, m)

	for i := range nodes {

		nodes[i] = make([]Node, n)

		for j := range nodes[i] {

			node := Node{}
			node.Init(i, j)
			nodes[i][j] = node

		}
	}

	b.m = m
	b.n = n
	b.nodes = nodes
}

func (wt *WildTravelers) Init(m, n int) {
	var wilds = make([][]WildTraveler, m)

	for i := range wilds {

		wilds[i] = make([]WildTraveler, n)

		for j := range wilds[i] {

			wild := WildTraveler{}
			wilds[i][j] = wild

		}
	}

	wt.m = m
	wt.n = n
	wt.wilds = wilds
}

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

	board = Board{}
	board.Init(m, n)

	wildTravelers = WildTravelers{}
	wildTravelers.Init(m, n)

	camera = Camera{}
	camera.Init()

	for column := 0; column < m; column++ {
		for row := 0; row < n; row++ {
			node := board.nodes[column][row]
			waitGroup.Add(1)
			go node.Handle(&waitGroup)
		}
	}

	waitGroup.Add(1)
	go HandleSpawning(&waitGroup)

	waitGroup.Add(1)
	go HandleBadThingsSpawning(&waitGroup)

	waitGroup.Add(1)
	go camera.Handle(&waitGroup)

	waitGroup.Add(1)
	go DisplayBoardPeriodically(&waitGroup)

	waitGroup.Wait()
}

func HandleSpawning(waitGroup *sync.WaitGroup) {
	defer waitGroup.Done()

	var count = 0
	var x, y int

	for count < k {

		if rand.Float32() < probability {
			x = rand.Intn(m)
			y = rand.Intn(n)

			ticket := Ticket{
				by:   fmt.Sprintf("%02d", count+1),
				at:   Coords{x, y},
				done: make(chan TicketResult)}

			node := board.nodes[x][y]
			node.PutTicket(Reservation, ticket)

			if result := <-ticket.done; result.success {
				node.PutTicket(Entrance, ticket)

				if result := <-ticket.done; result.success {
					count++

					traveller := Traveller{}
					traveller.Init(ticket.by, x, y)

					waitGroup.Add(1)
					go traveller.Handle(waitGroup, &board)
				}
			}
		}

		time.Sleep(3 * delay * time.Second)
	}
}

func HandleBadThingsSpawning(wg *sync.WaitGroup) {
	defer wg.Done()

	var x, y int

	for {
		if rand.Float32() < probability {

			x = rand.Intn(m-1) + 1
			y = rand.Intn(n-1) + 1
			node := board.nodes[x][y]

			if rand.Float32() < 0 {
				ticket := HazardTicket{
					at:   Coords{x, y},
					name: "##",
					done: make(chan bool)}

				node.PutTicket(HazardPrepare, ticket)

				if <-ticket.done {
					hazard := Hazard{}
					hazard.Init(ticket.name, x, y)

					node.PutTicket(HazardCreate, ticket)

					if <-ticket.done {
						// println("Hazard created: ", x, y)
						waitGroup.Add(1)
						go hazard.Handle(wg, &board)
					}
				}
			} else {
				ticket := WildTicket{
					by:   "**",
					at:   Coords{x, y},
					done: make(chan TicketResult)}

				node.PutTicket(WildReserve, ticket)

				if result := <-ticket.done; result.success {
					wild := WildTraveler{}
					wild.Init("**", x, y)
					wildTravelers.wilds[x][y] = wild
					ticket.entity = wild

					node.PutTicket(WildCreate, ticket)

					if result := <-ticket.done; result.success {
						// println("Wild traveler created: ", x, y, " column, row: ", wild.column, wild.row)
						waitGroup.Add(1)
						go wild.Handle(wg, &board)
					}
				}
			}
		}

		time.Sleep(5 * delay * time.Second)
	}
}

func DisplayBoardPeriodically(wg *sync.WaitGroup) {
	defer wg.Done()

	ticker := time.NewTicker(4 * delay * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			request := PicRequest{
				picture: make(chan [][]string),
				done:    make(chan bool)}

			camera.PutCamera(TakePic, request)
			picture := <-request.picture

			if <-request.done {

				for i := range picture {
					for j := range picture[i] {
						fmt.Printf(picture[i][j])
					}
					fmt.Printf("\n")
				}
				fmt.Println()
				fmt.Println()
				fmt.Println()
			}
		}
	}
}
