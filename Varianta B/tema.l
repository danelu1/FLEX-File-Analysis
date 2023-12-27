%{
#include <stdio.h>

int brackets = 0;
%}

%option stack

%s ARTICLE INPROCEEDINGS BOOK
%s IGNORE_NON_FIELDS
%s EXTRACT_INFO_TITLE EXTRACT_INFO
%s OTHER_RECORDINGS

%%

"%"[^\n]*[\n]* { }
\{|\} { }
\n{2,} { printf("\n"); }


@[aA][rR][tT][iI][cC][lL][eE][ \t]*\{[ \t]*[a-zA-Z0-9]+[ \t]*\,[ \t]*[\n]+ {
    printf("Articol in revista:\n");
    brackets++;
    yy_push_state(ARTICLE);
}

@[bB][oO][oO][kK][ \t]*\{[ \t]*[a-zA-Z0-9]+[ \t]*\,[ \t]*[\n]+ {
    printf("Carte:\n");
    brackets++;
    yy_push_state(BOOK);
}

@[iI][nN][pP][rR][oO][cC][eE][eE][dD][iI][nN][gG][sS][ \t]*\{[ \t]*[a-zA-Z0-9]+[ \t]*\,[ \t]*[\n]+ {
    printf("Articol la conferinta:\n");
    brackets++;
    yy_push_state(INPROCEEDINGS);
}

@[a-zA-Z0-9]+[ \t]*\{[ \t]*[a-zA-Z0-9]+[ \t]*\,[ \t]*[\n]+ {
    yy_push_state(OTHER_RECORDINGS);
}

<OTHER_RECORDINGS>[^\n]+\n {
    yy_pop_state();
}

"title"[ \t]*\=[ \t]* {
    printf("\tTitlu: ");
    yy_push_state(EXTRACT_INFO_TITLE);
}

"author"[ \t]*\=[ \t]* {
    printf("\tAutor: ");
    yy_push_state(EXTRACT_INFO);
}

"journal"[ \t]*\=[ \t]* {
    printf("\tRevista: ");
    yy_push_state(EXTRACT_INFO);
}

<ARTICLE>"booktitle"[ ]*\=[ ]* {
    printf("\tCarte: ");
    yy_push_state(EXTRACT_INFO);
}

<BOOK>"booktitle"[ ]*\=[ ]* {
    printf("\tCarte: ");
    yy_push_state(EXTRACT_INFO);
}

<INPROCEEDINGS>"booktitle"[ ]*\=[ ]* {
    printf("\tConferinta: ");
    yy_push_state(EXTRACT_INFO);
}

"year"[ \t]*\=[ \t]* {
    printf("\tAnul publicarii: ");
    yy_push_state(EXTRACT_INFO);
}

"doi"[ \t]*\=[ \t]* {
    printf("\tDOI: ");
    yy_push_state(EXTRACT_INFO);
}

"organization"[ \t]*\=[ \t]* {
    printf("\tOrganizatie: ");
    yy_push_state(EXTRACT_INFO);
}

"number"[ \t]*\=[ \t]* {
    printf("\tNumar versiune: ");
    yy_push_state(EXTRACT_INFO);
}

"pages"[ \t]*\=[ \t]* {
    printf("\tPagini: ");
    yy_push_state(EXTRACT_INFO);
}

"volume"[ \t]*\=[ \t]* {
    printf("\tVolum: ");
    yy_push_state(EXTRACT_INFO);
}

"publisher"[ \t]*\=[ \t]* {
    printf("\tEditura: ");
    yy_push_state(EXTRACT_INFO);
}

[a-zA-Z0-9]+[ \t]*\=[ \t]* { 
    yy_push_state(IGNORE_NON_FIELDS);
}

<IGNORE_NON_FIELDS>[^\n]+\n { 
    yy_pop_state();
}

<EXTRACT_INFO>\{[^}]+\}\, {
    yytext[yyleng - 2] = '\0';
    printf("%s", yytext + 1);
    yy_pop_state();
}

<EXTRACT_INFO>[0-9]+\, {
    yytext[yyleng - 1] = '\0';
    printf("%s", yytext);
    yy_pop_state();
}

<EXTRACT_INFO>\{[^}]+\}\n\} {
    yytext[yyleng - 3] = '\0';
    printf("%s\n", yytext + 1);
    yy_pop_state();
    yy_pop_state();
}

<EXTRACT_INFO>[0-9]+[ \t]*\n\} {
    yytext[yyleng - 3] = '\0';
    printf("%s\n", yytext + 1);
    yy_pop_state();
    yy_pop_state();
}

<EXTRACT_INFO_TITLE>\{[^}]+\}\, {
    yytext[yyleng - 2] = '\0';
    printf("\"%s\"", yytext + 1);
    yy_pop_state();
}

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) 
{
    yyin = fopen(argv[1], "r");
    if (!yyin)
    {
        printf("File does not exist!\n");
        exit(1);
    }

    yylex();
    fclose(yyin);
}