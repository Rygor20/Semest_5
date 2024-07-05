%{
#include <stdio.h>

int keep = 0;
%}

%%
\"(.*?)\"                                                           { fprintf(yyout, "%s", yytext); }  /* Just write if inside quotation marks */
"#include "[ \t]*\<(.*?)\>                                          { fprintf(yyout, "%s", yytext); }  /* Just write if inside import format */
"/"(\/|\\\n\/)(\/|\\\n\/)(.|\\\n)*$                                 { if (keep)
                                                                        {
                                                                            fprintf(yyout, "%s", yytext);
                                                                        } 
                                                                        else 
                                                                        {
                                                                            fprintf(yyout, " ");
                                                                        } 
                                                                    }
"/"(\/|\\\n\/)(\!|\\\n\!)[^/](.|\\\n)*$                             { if (keep)
                                                                        {
                                                                            fprintf(yyout, "%s", yytext);
                                                                        } 
                                                                        else 
                                                                        {
                                                                            fprintf(yyout, " ");
                                                                        } 
                                                                    }
"/"(\*|\\\n\*)(\*|\\\n\*)([^*]|"*"+[^*/])*(\*|\\\n\*)(\/|\\\n\/)    { if (keep)
                                                                        {
                                                                            fprintf(yyout, "%s", yytext);
                                                                        } 
                                                                        else 
                                                                        {
                                                                            fprintf(yyout, " ");
                                                                        } 
                                                                    }
"/"(\*|\\\n\*)(\!|\\\n\!)([^*]|"*"+[^*/])*(\*|\\\n\*)(\/|\\\n\/)    { if (keep)
                                                                        {
                                                                            fprintf(yyout, "%s", yytext);
                                                                        } 
                                                                        else 
                                                                        {
                                                                            fprintf(yyout, " ");
                                                                        } 
                                                                    }
"/"(\*|\\\n\*)([^*]|"*"+[^*/])*(\*|\\\n\*)(\/|\\\n\/)               { /* Ignoruj komentarze wieloliniowe */ }
"/"(\/|\\\n\/)(.|\\\n)*$                                            { /* Ignoruj komentarze jednoliniowe */ }
.|\n                                                                { fprintf(yyout, "%s", yytext); } /* Wypisz resztę tekstu */
%%

int yywrap() {
    return 1; // EOF
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <file_path> (0 = remove, 1 = keep)\n", argv[0]);
        return 1;
    }

    keep = atoi(argv[2]);
    FILE* input_file = fopen(argv[1], "r");

    if (input_file == NULL) {
        fprintf(stderr, "Can't open file %s\n", argv[1]);
        return 1;
    }

    FILE* output_file = fopen("answers/zad3_ans.cpp", "w");

    if (output_file == NULL) {
        fprintf(stderr, "Can't open file zad3_ans.txt\n");
        fclose(input_file);
        return 1;
    }

    yyin = input_file;
    yyout = output_file;

    yylex();

    fclose(input_file);
    fclose(output_file);

    return 0;
}