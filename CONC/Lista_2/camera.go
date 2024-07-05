package main

import (
	"sync"
)

type Camera struct {
	picture    [][]string
	ch_takepic chan PicRequest
	ch_modify  chan PicData
}

func (c *Camera) Handle(wg *sync.WaitGroup) {
	defer wg.Done()

	for {
		select {
		case ticket := <-c.ch_modify:
			move := ticket.move
			from_x := move.from.x
			from_y := move.from.y
			to_x := move.to.x
			to_y := move.to.y

			// fmt.Printf("from_x: %d, from_y: %d, to_x: %d, to_y: %d\n", from_x, from_y, to_x, to_y)

			if from_x != 0 {
				from_x = 2 * from_x
			}
			if from_y != 0 {
				from_y = 2 * from_y
			}
			if to_x != 0 {
				to_x = 2 * to_x
			}
			if to_y != 0 {
				to_y = 2 * to_y
			}

			// if from_x != to_x || from_y != to_y
			// if !((from_x == to_x && from_y == to_y) && from_x == 0)

			if !((from_x == to_x && from_y == to_y) && from_x == 0) {

				if from_x >= 0 && from_y >= 0 {
					c.picture[from_x][from_y] = "[]"
				}
				c.picture[to_x][to_y] = ticket.who

				if from_x >= 0 && from_y >= 0 && to_x >= 0 && to_y >= 0 {
					if from_x < to_x {
						c.picture[from_x+1][from_y] = "||"
					} else if from_x > to_x {
						c.picture[from_x-1][from_y] = "||"
					}

					if from_y < to_y {
						c.picture[from_x][from_y+1] = "=="
					} else if from_y > to_y {
						c.picture[from_x][from_y-1] = "=="
					}
				}
			}

			ticket.done <- true

		case ticket := <-c.ch_takepic:
			pictureCopy := deepCopy(c.picture)
			ticket.picture <- pictureCopy
			c.clearPaths()
			ticket.done <- true

		}
	}
}

func (c *Camera) PutCamera(channel Channel, data interface{}) {
	switch channel {
	case Modify:
		c.ch_modify <- data.(PicData)

	case TakePic:
		c.ch_takepic <- data.(PicRequest)
	}
}

func (c *Camera) Init() {
	c.newPicture()
	c.ch_takepic = make(chan PicRequest)
	c.ch_modify = make(chan PicData)
}

func (c *Camera) newPicture() {
	var picture = make([][]string, (board.m + board.m - 1))

	for z := range picture {

		picture[z] = make([]string, (board.n + board.n - 1))

		for y := range picture[z] {
			if z%2 == 0 && y%2 == 0 {
				picture[z][y] = "[]"
			} else {
				picture[z][y] = "  "
			}
		}
	}

	c.picture = picture
}

func (c *Camera) clearPaths() {
	for z := range c.picture {
		for y := range c.picture[z] {
			if c.picture[z][y] == "||" || c.picture[z][y] == "==" {
				c.picture[z][y] = "  "
			} else if c.picture[z][y] == "#!" {
				c.picture[z][y] = "[]"
			}
		}
	}
}

func deepCopy(src [][]string) [][]string {
	dst := make([][]string, len(src))
	for i := range src {
		dst[i] = make([]string, len(src[i]))
		copy(dst[i], src[i])
	}
	return dst
}
