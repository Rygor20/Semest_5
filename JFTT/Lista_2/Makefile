all: zad1 zad2 zad3 zad4

zad1: zad1.c
	gcc -o zad1 zad1.c

zad1.c: zad1.l
	flex -o zad1.c zad1.l

zad2: zad2.c
	gcc -o zad2 zad2.c

zad2.c: zad2.l
	flex -o zad2.c zad2.l

zad3: zad3.c
	gcc -o zad3 zad3.c

zad3.c: zad3.l
	flex -o zad3.c zad3.l

zad4: zad4.c
	gcc -o zad4 zad4.c -lm

zad4.c: zad4.l
	flex -o zad4.c zad4.l

clean:
	rm zad1.c zad1 zad2.c zad2 zad3.c zad3 zad4.c zad4