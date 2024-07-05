package main

import (
	"sync"
	"time"
)

// STRUCT HOLDING HAZARD OBJECT
type WildTraveler struct {
	id          string
	column      int
	row         int
	prev_column int
	prev_row    int
	at_hazard   bool
	ch_move_out chan Ticket
}

func (w *WildTraveler) Handle(wg *sync.WaitGroup, board *Board) {
	defer wg.Done()

	timeout := time.After(100 * delay * time.Second)

	for {
		select {
		case ticket := <-w.ch_move_out:
			// println("Wild traveler got mentioned")
			// println("Old node/current node at: ", w.column, w.row)
			node_new := Node{}
			request := WildTicket{
				by:     "**",
				entity: *w,
				at:     Coords{w.column, w.row},
				done:   make(chan TicketResult)}

			// println("Before for in Wild Traveler")
			for _, direction := range []Coords{{0, -1}, {0, 1}, {-1, 0}, {1, 0}} {
				newColumn, newRow := w.column+direction.x, w.row+direction.y
				// println("Generated cords: ", newColumn, newRow)

				if newColumn >= 0 && newColumn < n && newRow >= 0 && newRow < m && (newColumn != ticket.at.x || newRow != ticket.at.y) {
					node_new = board.nodes[newColumn][newRow]
					// println("Entity that sent move out at: ", ticket.at.x, ticket.at.y)
					// println("Checking node at: ", newColumn, newRow)
					node_new.PutTicket(WildReserve, request)

					if result := <-request.done; result.success {
						// println("Reservation was successful")
						// node_old.PutTicket(WildDepart, request)
						// println("Put ticket into WildDepart")

						node_new.PutTicket(WildEntrance, request)

						if result := <-request.done; result.success {
							// println("Entrance was successful")
							w.prev_column = w.column
							w.prev_row = w.row
							w.column = newColumn
							w.row = newRow

							ticket.done <- TicketResult{
								success:  true,
								hazard:   false,
								location: Coords{w.column, w.row},
							}

							// println("WILD TRAVELER MOVED to: ", w.column, w.row)

							return
						}

						// if result := <-request.done; result.success {
						// 	println("Departure was successful")
						// 	node_new.PutTicket(WildEntrance, request)

						// 	if result := <-ticket.done; result.success {
						// 		println("Entrance was successful")
						// 		w.prev_column = w.column
						// 		w.prev_row = w.row
						// 		w.column = newColumn
						// 		w.row = newRow

						// 		ticket.done <- TicketResult{
						// 			success:  true,
						// 			hazard:   false,
						// 			location: Coords{w.column, w.row},
						// 		}

						// 		println("WILD TRAVELER MOVED!")

						// 		return
						// 	}
						// }
					}
				}
			}
			// println("None of the cords was correct, sending false message")

			ticket.done <- TicketResult{
				success:  false,
				hazard:   false,
				location: Coords{w.column, w.row},
			}

			// println("False message sent")

		case <-timeout:
			ticket := WildTicket{
				by:   "**",
				at:   Coords{w.column, w.row},
				done: make(chan TicketResult)}

			node_at := board.nodes[w.column][w.row]

			node_at.PutTicket(WildDeath, ticket)

			if result := <-ticket.done; result.success {
				// println("Death of Wild at: ", w.column, w.row)
				break
			}
		}
	}
}

func (w *WildTraveler) PutWildTicket(channel Channel, data interface{}) {
	switch channel {

	case MoveOut:
		w.ch_move_out <- data.(Ticket)

	}
}

func (w *WildTraveler) Init(id string, column, row int) {
	w.id = id
	w.column = column
	w.row = row
	w.prev_column = -1
	w.prev_row = -1
	w.at_hazard = false
	w.ch_move_out = make(chan Ticket)
}
