%{
#include <stdio.h>
%}

%%
"<"[^ \t\n]+[ ][^ \t\n]+"="\"(.*?)\"                    { fprintf(yyout, "%s", yytext); }  /* Just write if inside quotation marks */
"<![CDATA"(.|\n)*"]]>"                           { fprintf(yyout, "%s", yytext); }  /* Just write if in CDATA format */
\n[ \t]*"<!--"([^-]*(-[^-]+)*)*"-->"\n      { fprintf(yyout, "\n"); } /* Remove fragment of text between <!-- and -->, only if comment without '--' in it, only comment in line */
"<!--"([^-]*(-[^-]+)*)*"-->"                { } /* Remove fragment of text between <!-- a -->, only if comment without '--' in it */
.                                           { fprintf(yyout, "%s", yytext); } /* Everythin else without a change */
%%

int yywrap() {
    return 1; // EOF
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return 1;
    }

    FILE* input_file = fopen(argv[1], "r");

    if (input_file == NULL) {
        fprintf(stderr, "Can't open file %s\n", argv[1]);
        return 1;
    }

    FILE* output_file = fopen("answers/zad2_ans.html", "w");

    if (output_file == NULL) {
        fprintf(stderr, "Can't open file zad2_ans.txt\n");
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