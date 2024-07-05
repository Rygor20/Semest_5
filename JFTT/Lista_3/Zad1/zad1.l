%option noyywrap

%{

#include "zad1y.hpp"

extern int yylex();

%}


%%
\\\n                    { /* Ignoruj znaki nowej linii na początku linii */ }                                    
[[:digit:]]+            { yylval = atoi(yytext); return NUM; }
[ \t]                   { /* Ignoruj białe znaki */ }
"(" {return '(';}
")" {return ')';}
"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}
"^" {return '^';}
\n  {return '\n';}
^#(.|\\\n)*\n           { /* Ignoruj linie komentarza i obsługa podziału linii */ }
.   {return ERR;}
%%