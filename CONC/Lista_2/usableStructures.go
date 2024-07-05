package main

type Ticket struct {
	by     string
	at     Coords
	entity Traveller
	done   chan TicketResult
}

type TicketResult struct {
	success  bool
	hazard   bool
	location Coords
}

type TicketInterface interface {
	Put(channel Channel, data interface{})
}

type HazardTicket struct {
	name string
	at   Coords
	done chan bool
}

type WildTicket struct {
	by     string
	entity WildTraveler
	at     Coords
	done   chan TicketResult
}

type PicData struct {
	who  string
	move Path
	done chan bool
}

type PicRequest struct {
	picture chan [][]string
	done    chan bool
}

type Coords struct {
	x int
	y int
}

type Path struct {
	from Coords
	to   Coords
}

type Channel int

const (
	Reservation Channel = iota
	Entrance
	Departure
	HazardPrepare
	HazardCreate
	HazardDeath
	WildReserve
	WildEntrance
	WildCreate
	WildDeath
	Modify
	TakePic
	MoveOut
)

type Direction int

const (
	North Direction = iota
	South
	West
	East
)

type Threat struct {
	existenceTime int
	coords        Coords
}
