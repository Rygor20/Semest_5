%option noyywrap
%option yylineno
%option nounput

%{

#include <iostream>
#include <string>
#include <vector>
#include "parser.h"

%}

%%

"PROCEDURE"     { return PROCEDURE; }
"IS"            { return IS; }
"IN"            { return IN; }
"END"           { return END; }

"PROGRAM"       { return PROGRAM; }

"IF"            { return IF; }
"THEN"          { return THEN; }
"ELSE"          { return ELSE; }
"ENDIF"         { return ENDIF; }

"WHILE"         { return WHILE; }
"DO"            { return DO; }
"ENDWHILE"      { return ENDWHILE; }

"REPEAT"        { return REPEAT; }
"UNTIL"         { return UNTIL; }

"READ"          { return READ; }
"WRITE"         { return WRITE; }

":="            { return ASSIGN; }

"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MULT; }
"/"             { return DIV; }
"%"             { return MOD; }

"="             { return EQ; }
"!="            { return NEQ; }
">"             { return GT; }
"<"             { return LT; }
">="            { return GEQ; }
"<="            { return LEQ; }

"("             { return '('; }
")"             { return ')'; }
"["             { return '['; }
"]"             { return ']'; }
","             { return ','; }
";"             { return ';'; }

"T"             { return 'T'; }

[_a-z]+         { yylval.pidentifier = new std::string(yytext); return pidentifier; }
[0-9]+          { yylval.num = std::stoll(yytext); return num; }

[ \t]*#.*$     { /* Ignore comment */ }

[ \t\r\n]+      { /* Ignore whitespaces*/ }

.               { return ERROR; }

%%