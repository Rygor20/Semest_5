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
	n         int
	forks     []chan bool
	table     []TableEntry
	waitGroup sync.WaitGroup
)

func validateArg(arg string, name string) (int, error) {
	val, err := strconv.Atoi(arg)
	if err != nil {
		return 0, fmt.Errorf("Error: %s is not integer", name)
	}
	return val, nil
}

func displayTable() {
	for _, entry := range table {
		if entry.forkLeft != entry.forkRight {
			fmt.Printf("  %2d | %2d | %2d\n", entry.forkLeft, entry.philosopherId, entry.forkRight)
		}
	}
	fmt.Println()
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Correct usage: go run dpProblem_asymetric.go n")
		return
	}

	var err error
	if n, err = validateArg(os.Args[1], "n"); err != nil {
		fmt.Println(err)
		return
	}

	if n < 2 {
		fmt.Println("Error: One fork per Philosopher, at least 2 Philosophers required")
		return
	}

	forks = make([]chan bool, n)
	for i := 0; i < n; i++ {
		forks[i] = make(chan bool, 1)
	}

	table = make([]TableEntry, n)

	for i := 0; i < n; i++ {
		waitGroup.Add(1)
		go HandlePhilosopher(&waitGroup, i)
	}

	waitGroup.Wait()
}

func HandlePhilosopher(waitGroup *sync.WaitGroup, i int) {
	defer waitGroup.Done()

	for {
		// Thinking
		thinkingTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(thinkingTime * time.Second)

		// Pick up Forks but consider parity of i variable
		if i%2 == 0 {
			forks[i] <- true
			forks[(i+1)%n] <- true
		} else {
			forks[(i+1)%n] <- true
			forks[i] <- true
		}

		// Adding entry to the Table and displaying it
		entry := TableEntry{
			forkLeft:      i,
			philosopherId: i,
			forkRight:     (i + 1) % n,
		}
		table[i] = entry
		displayTable()

		// Eating
		eatingTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(eatingTime * time.Second)

		// Removing entry from the Table and displaying it
		table[i] = TableEntry{}
		displayTable()

		// Put down Forks
		<-forks[i]
		<-forks[(i+1)%n]
	}
}

type TableEntry struct {
	forkLeft      int
	philosopherId int
	forkRight     int
}
