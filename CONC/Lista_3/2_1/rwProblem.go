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
	n            int
	m            int
	readCount    int
	table        []TableEntry
	writeChannel chan bool
	readChannel  chan bool
	waitGroup    sync.WaitGroup
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
		if entry.personId != 0 {
			fmt.Printf("  %2d | %s\n", entry.personId, entry.personStatus)
		}
	}
	fmt.Println()
}

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Correct usage: go run rwProblem.go n m")
		return
	}

	var err error
	if n, err = validateArg(os.Args[1], "n"); err != nil {
		fmt.Println(err)
		return
	}

	if m, err = validateArg(os.Args[2], "m"); err != nil {
		fmt.Println(err)
		return
	}

	if n < 2 {
		fmt.Println("Error: One fork per Philosopher, at least 2 Philosophers required")
		return
	}

	greater := n
	if n < m {
		greater = m
	}

	table = make([]TableEntry, greater)

	writeChannel = make(chan bool, 1)

	readChannel = make(chan bool, 1)

	for i := 0; i < n; i++ {
		waitGroup.Add(1)
		go HandleReader(&waitGroup, i)
	}

	for i := 0; i < m; i++ {
		waitGroup.Add(1)
		go HandleWriter(&waitGroup, i)
	}

	waitGroup.Wait()
}

func HandleReader(waitGroup *sync.WaitGroup, i int) {
	defer waitGroup.Done()

	for {
		// Sleep outside the library
		sleepTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(sleepTime * time.Second)

		// Attempt to start reading and sign in
		readChannel <- true
		readCount += 1

		// To ensure that no writer can enter if there is even one reader
		if readCount == 1 {
			writeChannel <- true
		}

		entry := TableEntry{
			personId:     i + 1,
			personStatus: "Reader",
		}
		table[i] = entry
		displayTable()

		<-readChannel

		// Reading
		readingTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(readingTime * time.Second)

		// Signal that you want to leave
		readChannel <- true
		readCount -= 1

		table[i] = TableEntry{}
		displayTable()

		// No readers left, possible writer can start writing
		if readCount == 0 {
			<-writeChannel
		}

		<-readChannel
	}
}

func HandleWriter(waitGroup *sync.WaitGroup, i int) {
	defer waitGroup.Done()

	for {
		// Sleep outside the library
		sleepTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(sleepTime * time.Second)

		// Attempt to start writing if noone is present
		writeChannel <- true

		entry := TableEntry{
			personId:     i + 1,
			personStatus: "Writer",
		}

		table[i] = entry
		displayTable()

		// Writing
		writingTime := time.Duration(rand.Intn(5) + 1)
		time.Sleep(writingTime * time.Second)

		table[i] = TableEntry{}
		displayTable()

		// Signal that you stopped writing
		<-writeChannel
	}
}

type TableEntry struct {
	personId     int
	personStatus string
}
