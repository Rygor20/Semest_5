flags = -std=c++17 --pedantic -Wall -Wextra

all: parser lexer
	g++ $(flags) -o kompilator parser.c lexer.c identifiers.cpp compiler.cpp

parser:
	bison -d -o parser.c parser.y

lexer:
	flex -o lexer.c lexer.l
	
clean:
	rm lexer.c parser.c parser.h kompilator
