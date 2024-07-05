package main

import (
	"sync"
	"time"
)

// STRUCT HOLDING HAZARD OBJECT
type Hazard struct {
	id     string
	column int
	row    int
}

func (h *Hazard) Handle(waitGroup *sync.WaitGroup, board *Board) {
	defer waitGroup.Done()

	for {
		time.Sleep(8 * delay * time.Second)

		ticket := HazardTicket{
			name: "##",
			at:   Coords{h.column, h.row},
			done: make(chan bool)}

		node_at := board.nodes[h.column][h.row]

		node_at.PutTicket(HazardDeath, ticket)

		if <-ticket.done {
			break
		}
	}
}

func (h *Hazard) Init(id string, column, row int) {
	h.id = id
	h.column = column
	h.row = row
}
