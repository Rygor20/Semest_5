package main

import (
	"math/rand"
	"sync"
	"time"
)

// STRUCT HOLDING TRAVELLER OBJECT
type Traveller struct {
	id          string
	column      int
	row         int
	prev_column int
	prev_row    int
	at_hazard   bool
}

func (t *Traveller) Handle(waitGroup *sync.WaitGroup, board *Board) {
	defer waitGroup.Done()

	for {
		time.Sleep(delay * time.Second)

		if rand.Float32() < probability {
			x_mod, y_mod := t.GetCoords()

			switch Direction(rand.Intn(4)) {

			case North:
				if y_mod > 0 {
					y_mod -= 1
				}

			case South:
				if y_mod < n-1 {
					y_mod += 1
				}

			case West:
				if x_mod > 0 {
					x_mod -= 1
				}

			case East:
				if x_mod < m-1 {
					x_mod += 1
				}

			}

			x, y := t.GetCoords()

			if x == x_mod && y == y_mod {
				continue
			}

			ticket := Ticket{
				by:     t.id,
				entity: *t,
				done:   make(chan TicketResult)}

			node_old := board.nodes[x][y]
			node_new := board.nodes[x_mod][y_mod]

			node_new.PutTicket(Reservation, ticket)

			if result := <-ticket.done; result.success {
				node_old.PutTicket(Departure, ticket)

				if result := <-ticket.done; result.success {
					node_new.PutTicket(Entrance, ticket)

					if result := <-ticket.done; result.success {
						t.SetCoords(x_mod, y_mod)
						t.SetPrevCoords(x, y)

						if result.hazard {
							break
						}
					}
				}
			}
		}
	}
}

func (t *Traveller) Init(id string, column, row int) {
	t.id = id
	t.column = column
	t.row = row
	t.prev_column = -1
	t.prev_row = -1
	t.at_hazard = false
}

func (t *Traveller) GetCoords() (int, int) {
	return t.column, t.row
}

func (t *Traveller) SetCoords(column, row int) {
	t.column = column
	t.row = row
}

func (t *Traveller) GetPrevCoords() (int, int) {
	return t.prev_column, t.prev_row
}

func (t *Traveller) SetPrevCoords(column, row int) {
	t.prev_column = column
	t.prev_row = row
}
