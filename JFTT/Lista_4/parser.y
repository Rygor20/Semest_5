%{

#include <iostream>
#include <string>
#include <vector>
#include <cstdio>

#include "compiler.hpp"
#include "identifiers.hpp"

int yylex();
int yyparse();
int yyerror(std::string s);
extern FILE *yyin;
extern int yylineno;

%}

%union {
    std::string *pidentifier;
    long long num;

    struct Variable *var;
}

%start program_all

%token PROCEDURE IS IN END 
%token PROGRAM

%token ASSIGN IF THEN ELSE ENDIF WHILE DO ENDWHILE REPEAT UNTIL
%token READ WRITE

%token <pidentifier> pidentifier 
%token <num> num

%token T

//%token ADD SUB MULT DIV MOD
%token EQ NEQ GT LT GEQ LEQ

%token ERROR

%left ADD SUB
%left MULT DIV MOD

%type <var> value
%type <var> identifier
%type <var> expression
%type <var> condition
%type <var> REPEAT
%type <var> proc_head

%%

program_all:
    procedures                                                          { settle_main(); }
        main                                                            { end_program(); }
    |
;


procedures:   
    procedures PROCEDURE proc_head IS declarations IN commands END      {  finish_proc($3); }
    | procedures PROCEDURE proc_head IS IN commands END                 {  finish_proc($3); }
    |
;

main:         
    PROGRAM IS declarations IN commands END                             {  }
    | PROGRAM IS IN commands END                                        {  }
;

commands:
    commands command                                                    {  }
    | command                                                           {  }
;

command:
    identifier ASSIGN expression ';'                                    {  assign($1, $3, yylineno); }
    | IF condition THEN commands ELSE                                   {  if_else($2, yylineno); }
        commands ENDIF                                                  {  end_else($2, yylineno); }
    | IF condition THEN commands ENDIF                                  {  if_statement($2, yylineno); }
    | WHILE condition DO commands ENDWHILE                              {  while_block($2, yylineno); }
    | REPEAT                                                            {  $1 = repeat_set(); }
        commands UNTIL condition ';'                                    {  repeat_block($1, $5, yylineno); }
    | proc_call ';'                                                     {  }
    | READ identifier ';'                                               {  read($2, yylineno); }
    | WRITE value ';'                                                   {  write($2, yylineno); }
;

proc_head:    
    pidentifier                                                         {  setting_proc(*$1); }
        '(' args_decl ')'                                               {  $$ = procedure_head(*$1, yylineno); }
;

proc_call:    
    pidentifier                                                         {  call_proc(*$1, yylineno); }
        '(' args ')'                                                    {  finish_call(*$1, yylineno); }
;

declarations: 
    declarations ',' pidentifier                                        {  var_decl(*$3, yylineno - 1); }
    | declarations ',' pidentifier '[' num ']'                          {  tab_decl(*$3, $5, yylineno - 1); }
    | pidentifier                                                       {  var_decl(*$1, yylineno); }
    | pidentifier '[' num ']'                                           {  tab_decl(*$1, $3, yylineno); }
;

args_decl:    
    args_decl ',' pidentifier                                           {  arg_var_decl(*$3, yylineno - 1); }
    | args_decl ',' 'T' pidentifier                                     {  arg_tab_decl(*$4, yylineno - 1); }
    | pidentifier                                                       {  arg_var_decl(*$1, yylineno); }
    | 'T' pidentifier                                                   {  arg_tab_decl(*$2, yylineno); }
;

args:         
    args ',' pidentifier                                                {  set_arg(*$3, yylineno); }
    | pidentifier                                                       {  set_arg(*$1, yylineno); }
;

expression:   
    value                                                               {  $$ = only_value($1, yylineno); }
    | value ADD value                                                   {  $$ = add($1, $3, yylineno); }
    | value SUB value                                                   {  $$ = sub($1, $3, yylineno); }
    | value MULT value                                                  {  $$ = mult($1, $3, yylineno); }
    | value DIV value                                                   {  $$ = div($1, $3, yylineno); }
    | value MOD value                                                   {  $$ = mod($1, $3, yylineno); }
;

condition:    
    value EQ value                                                      {  $$ = equal($1, $3, yylineno); }
    | value NEQ value                                                   {  $$ = not_equal($1, $3, yylineno); }
    | value GT value                                                    {  $$ = greater($1, $3, yylineno); }
    | value LT value                                                    {  $$ = less($1, $3, yylineno); }
    | value GEQ value                                                   {  $$ = greater_equal($1, $3, yylineno); }
    | value LEQ value                                                   {  $$ = less_equal($1, $3, yylineno); }
;

value:
    num                                                                 {  $$ = val_num($1, yylineno); }
    | identifier                                                        {  $$ = val_id($1, yylineno); }
;

identifier:   
    pidentifier                                                         {  $$ = id_var(*$1, yylineno); }
    | pidentifier '[' num ']'                                           {  $$ = id_arr_num(*$1, $3, yylineno); }
    | pidentifier '[' pidentifier ']'                                   {  $$ = id_arr_pid(*$1, *$3, yylineno); }
;

%%

int main(int argc, char* argv[]) {
    if( argc != 3 ) {
        std::cerr << "Correct usage: ./compiler input_file_path output_file_path" << std::endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        std::cout << "File doesn't exist - " << yylineno << std::endl;
        return 1;
    }

    yyparse();

    write_to_file(argv[2]);

    return 0;
}

int yyerror(std::string s) {
    if (s == "syntax error") {
        error("The compiler encountered an unrecognizable symbol. Syntax error!", yylineno);
    }
    error(s, yylineno);
    return 1;
}
