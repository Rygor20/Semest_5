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
	monitor   *PhilosopherMonitor
	waitGroup sync.WaitGroup
)

func validateArg(arg string, name string) (int, error) {
	val, err := strconv.Atoi(arg)
	if err != nil {
		return 0, fmt.Errorf("Error: %s is not integer", name)
	}
	return val, nil
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Correct usage: go run dpProblem_monitor.go n")
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

	monitor = newMonitor()

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

		// Pick up Forks using PhilosopherMonitor
		monitor.pickForks(i)

		// Adding entry to the Table using PhilosopherMonitor and displaying it
		monitor.addToTable(i)

		// Eating
		eatingTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(eatingTime * time.Second)

		// Removing entry from the Table using PhilosopherMonitor and displaying it
		monitor.removeFromTable(i)

		// Put down Forks using PhilosopherMonitor
		monitor.putForks(i)
	}
}

type TableEntry struct {
	forkLeft      int
	philosopherId int
	forkRight     int
}

type PhilosopherMonitor struct {
	forks []chan bool
	table []TableEntry
}

func newMonitor() *PhilosopherMonitor {
	m := new(PhilosopherMonitor)

	m.forks = make([]chan bool, n)
	for i := 0; i < n; i++ {
		m.forks[i] = make(chan bool, 1)
	}

	m.table = make([]TableEntry, n)

	return m
}

func (pm *PhilosopherMonitor) pickForks(i int) {
	pm.forks[i] <- true
	pm.forks[(i+1)%n] <- true
}

func (pm *PhilosopherMonitor) putForks(i int) {
	<-pm.forks[i]
	<-pm.forks[(i+1)%n]
}

func (pm *PhilosopherMonitor) addToTable(i int) {
	entry := TableEntry{
		forkLeft:      i,
		philosopherId: i,
		forkRight:     (i + 1) % n,
	}
	pm.table[i] = entry
	pm.displayTable()
}

func (pm *PhilosopherMonitor) removeFromTable(i int) {
	pm.table[i] = TableEntry{}
	pm.displayTable()
}

func (pm *PhilosopherMonitor) displayTable() {
	for _, entry := range pm.table {
		if entry.forkLeft != entry.forkRight {
			fmt.Printf("  %2d | %2d | %2d\n", entry.forkLeft, entry.philosopherId, entry.forkRight)
		}
	}
	fmt.Println()
}
