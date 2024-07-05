%{
#include <stdio.h>

int saved_line_number;
int line_count = 0;
int word_count = 0;
%}

%%
^[ \t]+         { /* Remove white space at the beginning of row */ }
[ \t]+$         { /* Remove white space at the end of row */ }
[ \t]+          { fprintf(yyout, " "); } /* Replace multiple tabs or spaces with a singular space */
(\n[ \t]*)*\n   { fprintf(yyout, "\n"); line_count++; } /* Remove an empty line and update line count */
[^ \t\n]+       { fprintf(yyout, "%s", yytext); word_count++; } /* Write the rest to yyout and update word count */
%%

int yywrap() {
    int lastChar;
    long currentPosition;

    currentPosition = ftell(yyin);

    fseek(yyin, -1, SEEK_END);
    
    lastChar = fgetc(yyin);

    if (lastChar == ' ' || lastChar == '\t') {
        fseek(yyin, -1, SEEK_END);

        fseek(yyout, -1, SEEK_END);
        currentPosition = ftell(yyout);

        fprintf(yyout, "\n");
        line_count++;
    }

    fseek(yyin, currentPosition, SEEK_SET);

    printf("Line count: %d\nWord count: %d\n", line_count, word_count);
    //fprintf(yyout, "\nLine count: %d\nWord count: %d\n", line_count, word_count);
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

    FILE* output_file = fopen("answers/zad1_ans.txt", "w");

    if (output_file == NULL) {
        fprintf(stderr, "Can't open file zad1_ans.txt\n");
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