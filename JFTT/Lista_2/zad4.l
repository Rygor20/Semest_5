%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MAX_STACK_SIZE 100

int stack[MAX_STACK_SIZE];
int top = -1;
int error_flag = 0;  // Flag to indicate an error

void clearStack() {
    top = -1;
}

void set_error_flag() {
    error_flag = 1;
}

void push(int value) {
    if (top < MAX_STACK_SIZE - 1) {
        stack[++top] = value;
    } else {
        fprintf(stderr, "Błąd: Przepełnienie stosu.\n");
        set_error_flag();
    }
}

int pop() {
    if (top >= 0) {
        return stack[top--];
    } else {
        fprintf(stderr, "Błąd: Stos jest pusty.\n");
        set_error_flag();
        return 0;  // Return a default value (you may choose another approach)
    }
}

%}

%option noyywrap

%%
[-]?[0-9]+          { if (!error_flag) push(atoi(yytext)); }

[-+*/%^]           {
                        if (!error_flag && top < 1) {
                            fprintf(stderr, "Błąd: Za mało argumentów dla operacji %s.\n", yytext);
                            set_error_flag();
                            clearStack();
                        }
                        if (!error_flag && top >= 1) {
                            int b = pop();
                            int a = pop();
                            switch(yytext[0]) {
                                case '+': push(a + b); break;
                                case '-': push(a - b); break;
                                case '*': push(a * b); break;
                                case '/': 
                                    if (b != 0) {
                                        push(a / b);
                                    } else {
                                        fprintf(stderr, "Błąd: Dzielenie przez zero.\n");
                                        set_error_flag();
                                        clearStack();
                                    }
                                    break;
                                case '%':
                                    if (b != 0) {
                                        push(a % b);
                                    } else {
                                        fprintf(stderr, "Błąd: Dzielenie przez zero (modulo).\n");
                                        set_error_flag();
                                        clearStack();
                                    }
                                    break;
                                case '^': push(pow(a, b)); break;
                            }
                        } else {
                            set_error_flag();
                            clearStack();
                        }
                    }

\n                 {
                    if (!error_flag && top == -1) {
                        printf("Błąd: Za mało argumentów.\n");
                    } else if (!error_flag && top == 0) {
                        printf("Wynik: %d\n", pop());
                        clearStack();
                    } else if (!error_flag) {
                        fprintf(stderr, "Błąd: Za mało operatorów.\n");
                        clearStack();
                    }
                    error_flag = 0;  // Reset error flag after processing each line
                  }

[ \t]               ; // Ignore white spaces
.                  {
                    fprintf(stderr, "Błąd: Nieprawidłowy znak %s\n", yytext);
                    set_error_flag();
                    clearStack();
                  }
<<EOF>>             { error_flag = 0; }
%%

int main(void) {
    yylex();
    return 0;
}
