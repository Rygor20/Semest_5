package main

import (
	"sync"
)

var EMPTY = ". "

// STRUCTURE HOLDING NODE OBJECT
type Node struct {
	value             string
	x                 int
	y                 int
	reserved          bool
	taken             bool
	hazard            bool
	strike_detected   bool
	ch_reservation    chan Ticket
	ch_entrance       chan Ticket
	ch_departure      chan Ticket
	ch_hazard_prepare chan HazardTicket
	ch_hazard_create  chan HazardTicket
	ch_hazard_death   chan HazardTicket
	ch_wild_reserv    chan WildTicket
	ch_wild_entrance  chan WildTicket
	ch_wild_create    chan WildTicket
	ch_wild_death     chan WildTicket
}

func (n *Node) Handle(wg *sync.WaitGroup) {
	defer wg.Done()

	for {
		select {

		case ticket := <-n.ch_reservation:
			if (n.value == EMPTY || n.value == "##") && !n.reserved && !n.taken {
				n.value = ticket.by
				n.reserved = true
				ticket.done <- TicketResult{
					success:  true,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			} else if n.value == "**" && !n.reserved && n.taken {
				request := Ticket{
					by:   ticket.by,
					at:   ticket.at,
					done: make(chan TicketResult)}

				// println("We got ticket with 'at' attribute: ", ticket.at.x, ticket.at.y)
				// println("Node encountered at: ", n.x, n.y)

				wildTravelers.wilds[n.x][n.y].PutWildTicket(MoveOut, request)

				if result := <-request.done; result.success {
					// println("Successful request!")
					n.taken = false
					// wildTravelers.wilds[n.x][n.y] = WildTraveler{}

					// println("Value in ticket.by after successful request: ", ticket.by)
					n.value = ticket.by
					n.reserved = true
					ticket.done <- TicketResult{
						success:  true,
						hazard:   false,
						location: Coords{ticket.entity.row, ticket.entity.column},
					}
				} else {
					// println("Failed request request!")
					ticket.done <- TicketResult{
						success:  false,
						hazard:   false,
						location: Coords{ticket.entity.row, ticket.entity.column},
					}
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_entrance:
			if ticket.by == n.value && n.reserved && !n.taken {
				n.reserved = false
				n.taken = true

				path := Path{
					from: Coords{ticket.entity.prev_column, ticket.entity.prev_row},
					to:   Coords{ticket.entity.column, ticket.entity.row},
				}

				ticketCam := PicData{
					move: path,
					done: make(chan bool),
				}

				if n.hazard {
					ticketCam.who = "#!"
					n.strike_detected = true
				} else {
					ticketCam.who = ticket.by
				}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					if n.hazard {
						ticket.done <- TicketResult{
							success:  true,
							hazard:   true,
							location: Coords{ticket.entity.row, ticket.entity.column},
						}
					} else {
						ticket.done <- TicketResult{
							success:  true,
							hazard:   false,
							location: Coords{ticket.entity.row, ticket.entity.column},
						}
					}
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_departure:
			if ticket.by == n.value && !n.reserved && n.taken {
				n.taken = false
				n.value = EMPTY
				ticket.done <- TicketResult{
					success:  true,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_hazard_prepare:
			if n.value == EMPTY && !n.reserved && !n.taken && !n.hazard {
				n.value = ticket.name
				n.reserved = true
				ticket.done <- true
			} else {
				ticket.done <- false
			}

		case ticket := <-n.ch_hazard_create:
			if ticket.name == n.value && n.reserved && !n.taken && !n.hazard {
				n.reserved = false
				n.hazard = true

				path := Path{
					from: Coords{ticket.at.x, ticket.at.y},
					to:   Coords{ticket.at.x, ticket.at.y},
				}

				ticketCam := PicData{
					move: path,
					who:  ticket.name,
					done: make(chan bool)}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					ticket.done <- true
				}
			} else {
				ticket.done <- false
			}

		case ticket := <-n.ch_hazard_death:
			if n.hazard {
				n.hazard = false
				n.strike_detected = false
				n.value = EMPTY

				path := Path{
					from: Coords{ticket.at.x, ticket.at.y},
					to:   Coords{ticket.at.x, ticket.at.y},
				}

				ticketCam := PicData{
					move: path,
					who:  "[]",
					done: make(chan bool)}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					ticket.done <- true
				}

			} else if n.strike_detected {
				n.strike_detected = false
				n.hazard = false

				ticket.done <- true
			} else {
				ticket.done <- false
			}

		case ticket := <-n.ch_wild_reserv:
			if (n.value == EMPTY || n.value == "##") && !n.reserved && !n.taken {
				n.value = ticket.by
				n.reserved = true
				ticket.done <- TicketResult{
					success:  true,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_wild_entrance:
			if ticket.by == n.value && n.reserved && !n.taken {
				n.reserved = false
				n.taken = true
				// println("Entered: ", ticket.entity.id, ticket.entity.column, ticket.entity.row)
				wildTravelers.wilds[n.x][n.y] = ticket.entity

				path := Path{
					from: Coords{ticket.at.x, ticket.at.y},
					to:   Coords{n.x, n.y},
				}

				ticketCam := PicData{
					move: path,
					done: make(chan bool),
				}

				if n.hazard {
					ticketCam.who = "*!"
					n.strike_detected = true
				} else {
					ticketCam.who = ticket.by
				}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					if n.hazard {
						ticket.done <- TicketResult{
							success:  true,
							hazard:   true,
							location: Coords{ticket.entity.row, ticket.entity.column},
						}
					} else {
						ticket.done <- TicketResult{
							success:  true,
							hazard:   false,
							location: Coords{ticket.entity.row, ticket.entity.column},
						}
					}
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_wild_create:
			if ticket.by == n.value && n.reserved && !n.taken && !n.hazard {
				n.reserved = false
				n.taken = true
				wildTravelers.wilds[n.x][n.y] = ticket.entity

				path := Path{
					from: Coords{ticket.at.x, ticket.at.y},
					to:   Coords{ticket.at.x, ticket.at.y},
				}

				ticketCam := PicData{
					move: path,
					who:  ticket.by,
					done: make(chan bool)}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					ticket.done <- TicketResult{
						success:  true,
						hazard:   false,
						location: Coords{ticket.at.x, ticket.at.y},
					}
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}

		case ticket := <-n.ch_wild_death:
			if n.value == ticket.by {
				n.taken = false
				n.value = EMPTY
				wildTravelers.wilds[n.x][n.y] = WildTraveler{}

				path := Path{
					from: Coords{ticket.at.x, ticket.at.y},
					to:   Coords{ticket.at.x, ticket.at.y},
				}

				ticketCam := PicData{
					move: path,
					who:  "[]",
					done: make(chan bool)}

				camera.PutCamera(Modify, ticketCam)

				if <-ticketCam.done {
					ticket.done <- TicketResult{
						success:  true,
						hazard:   false,
						location: Coords{ticket.at.x, ticket.at.y},
					}
				}
			} else {
				ticket.done <- TicketResult{
					success:  false,
					hazard:   false,
					location: Coords{ticket.entity.row, ticket.entity.column},
				}
			}
		}
	}
}

func (n *Node) PutTicket(channel Channel, data interface{}) {
	switch channel {

	case Reservation:
		n.ch_reservation <- data.(Ticket)

	case Entrance:
		n.ch_entrance <- data.(Ticket)

	case Departure:
		n.ch_departure <- data.(Ticket)

	case HazardPrepare:
		n.ch_hazard_prepare <- data.(HazardTicket)

	case HazardCreate:
		n.ch_hazard_create <- data.(HazardTicket)

	case HazardDeath:
		n.ch_hazard_death <- data.(HazardTicket)

	case WildReserve:
		n.ch_wild_reserv <- data.(WildTicket)

	case WildEntrance:
		n.ch_wild_entrance <- data.(WildTicket)

	case WildCreate:
		n.ch_wild_create <- data.(WildTicket)

	case WildDeath:
		n.ch_wild_death <- data.(WildTicket)

	}
}

// InitPool FUNCTION - CREATES NODE OBJECT
func (n *Node) Init(x, y int) {
	n.value = EMPTY
	n.x = x
	n.y = y
	n.reserved = false
	n.taken = false
	n.hazard = false
	n.strike_detected = false
	n.ch_reservation = make(chan Ticket)
	n.ch_entrance = make(chan Ticket)
	n.ch_departure = make(chan Ticket)
	n.ch_hazard_prepare = make(chan HazardTicket)
	n.ch_hazard_create = make(chan HazardTicket)
	n.ch_hazard_death = make(chan HazardTicket)
	n.ch_wild_reserv = make(chan WildTicket)
	n.ch_wild_entrance = make(chan WildTicket)
	n.ch_wild_create = make(chan WildTicket)
	n.ch_wild_death = make(chan WildTicket)
}
