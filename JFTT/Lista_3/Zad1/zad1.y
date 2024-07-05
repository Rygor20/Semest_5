%{


#include <iostream>
#include <string>
#define MAX_LIM 1234577

using namespace std;

int negat(int a, int order);

int add(int a, int b, int order);
int sub(int a, int b, int order);

int inverse(int a, int order);
int divide(int a, int b, int order);
int mult(int a, int b, int order);

int power(int a, int pow, int order);

extern int yylex();
extern int yyparse();
int yyerror(string s);

string error_msg = "";
string rpn = "";
int res = 0;


%}


%define api.value.type { int }

%token NUM
%token ERR
%left '+' '-'
%left '*' '/'
%left NEG
%nonassoc '^'


%%

input:
    %empty
    | input line
;

line: 
    exp '\n' { 
            cout << rpn << endl;
            cout << "Wynik:  " << $1 << endl; 
            rpn = "";
        }
    | error '\n' { 
            if (error_msg == "") 
                error_msg = "Błąd składni";
            cout << "Błąd: " << error_msg << endl; 
            rpn = ""; 
            error_msg = "";
        }
;

number:
    NUM                     { $$ = $1 % MAX_LIM; }
    | '-' number %prec NEG     { $$ = negat(-$2, MAX_LIM); }
;

exponent_number:
    NUM                     { $$ = $1 % (MAX_LIM - 1); }
    | '-' exponent_number %prec NEG     { $$ = negat(-$2, MAX_LIM - 1); }
;

exp: 
    number                          { rpn += to_string($1) + " "; $$ = $1; }
    | '-' '(' exp ')' %prec NEG     { rpn += "~ "; $$ = negat(-$3, MAX_LIM); }
    | '-' exp                       { rpn += "neg "; $$ = negat(-$2, MAX_LIM); }
    | '(' exp ')'                   { $$ = $2; }
    | exp '+' exp                   { rpn += "+ "; $$ = add($1, $3, MAX_LIM); }
    | exp '-' exp                   { rpn += "- "; $$ = sub($1, $3, MAX_LIM); }
    | exp '*' exp                   { rpn += "* "; $$ = mult($1, $3, MAX_LIM); }
    | exp '^' exponent              { rpn += "^ "; $$ = power($1, $3, MAX_LIM); }
    | exp '/' exp                   {  
                                      if ($3 == 0) { 
                                        error_msg = "Dzielenie przez 0"; 
                                        YYERROR; 
                                      } 
                                      else {
                                        res = divide($1, $3, MAX_LIM);
                                        if (res == -1){
                                            error_msg = "Inwersja nie istnieje"; 
                                            YYERROR;
                                        }
                                        else {
                                            rpn += "/ ";
                                            $$ = res;
                                        } 
                                      }
                                    }
;

exponent: 
    exponent_number                     { rpn += to_string($1) + " "; $$ = $1; }
    | '(' exponent ')'                  { $$ = $2; }
    | '-' '(' exponent ')' %prec NEG    { rpn += "~ "; $$ = negat(-$3, MAX_LIM - 1); }
    | exponent '+' exponent             { rpn += "+ "; $$ = add($1, $3, MAX_LIM - 1); }
    | exponent '-' exponent             { rpn += "- "; $$ = sub($1, $3, MAX_LIM - 1); }
    | exponent '*' exponent             { rpn += "* "; $$ = mult($1, $3, MAX_LIM - 1); }
    | exponent '/' exponent             {  
                                        if ($3 == 0) { 
                                            error_msg = "Dzielenie przez 0"; 
                                            YYERROR; 
                                        } 
                                        else {
                                            res = divide($1, $3, MAX_LIM - 1);
                                            if (res == -1){
                                                error_msg = "Inwersja nie istnieje"; 
                                                YYERROR;
                                            }
                                            else {
                                                rpn += "/ ";
                                                $$ = res;
                                            } 
                                        }
                                        }
;

%%


int negat(int a, int order) {
    while (a < 0) {
        a += order;
    }
    return a;
}

int add(int a, int b, int order) {
    return (a+b)%order;
}

int sub(int a, int b, int order) {
    return add(a, negat(-b, order), order);
}

int inverse(int a, int order) {
    for(int i = 0; i < order; i++) {
        if(mult(a, i, order) == 1) {
            return i;
        }
    }
    return -1;
}

int mult(int a, int b, int order) {
    return (int)((long long)a*b % order);
}

int divide(int a, int b, int order) {
    if(b == 0) {
        return -1;
    }
    int inv = inverse(b, order);
    if(inv == -1) {
        return -1;
    }
    return mult(a, inv, order);
}

int power(int a, int pow, int order) {
    if (pow == 0) {
        return 1;
    }
    int b = power(a, pow/2, order);
    b = mult(b, b, order);
    if(pow % 2 == 0) {
        return b;
    }
    return mult(b, a, order);
}

int yyerror(string s) {	
    return 0;
}

int main()
{
    yyparse();
    return 0;
}