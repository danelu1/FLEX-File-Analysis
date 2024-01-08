/* Sprincenatu Bogdan-Andrei 332CC */

%{
#include <stdio.h>

char author_surname[1001];
char author_name[1001];
%}

%option stack

%s ARTICLE INPROCEEDINGS BOOK
%s IGNORE_OTHER_FIELDS
%s EXTRACT_INFO_TITLE EXTRACT_INFO
%s AUTHOR NAME
%s PAGES EXTRACT_LAST_PAGE LAST
%s OTHER_RECORDINGS

alpha_numerical [a-zA-Z0-9]
numerical [0-9]
whitespace [ \t]
newline \n
newlines {whitespace}*{newline}+
line [^\n]+

comment "%"[^\n]*[\n]*
article [aA][rR][tT][iI][cC][lL][eE]{whitespace}*
book [bB][oO][oO][kK]{whitespace}*
inproceedings [iI][nN][pP][rR][oO][cC][eE][eE][dD][iI][nN][gG][sS]{whitespace}*
other_recording {alpha_numerical}+{whitespace}*
citation [a-zA-Z0-9\'\"-]
label {whitespace}*{citation}+{whitespace}*
value [^}]+

title {whitespace}*"title"{whitespace}*\={whitespace}*
publisher {whitespace}*"publisher"{whitespace}*\={whitespace}*
author {whitespace}*"author"{whitespace}*\={whitespace}*
booktitle {whitespace}*"booktitle"{whitespace}*\={whitespace}*
doi {whitespace}*"doi"{whitespace}*\={whitespace}*
organization {whitespace}*"organization"{whitespace}*\={whitespace}*
pages {whitespace}*"pages"{whitespace}*\={whitespace}*
number {whitespace}*"number"{whitespace}*\={whitespace}*
volume {whitespace}*"volume"{whitespace}*\={whitespace}*
year {whitespace}*"year"{whitespace}*\={whitespace}*
journal {whitespace}*"journal"{whitespace}*\={whitespace}*
other_field {whitespace}*[a-zA-Z0-9\-\_:\t.;\'\" ]+{whitespace}*\={whitespace}*

%%

{comment} { /*Ignoram comentariile*/ }
\{|\} { /*Ignoram acoladele*/ }
\n{2,} {
    // Inlocuim toate grupurile de cel putin 2 "\n" cu unul singur.
    printf("\n");
}


@{article}\{{label}\,{newlines} {
    // Am gasit un articol, printam mesajul corespunzator si
    // ne ducem la starea "ARTICLE"(in interiorul lui).
    // La fel facem si pentru restul tipurilor.
    printf("Articol in revista:\n");
    yy_push_state(ARTICLE);
}

@{book}\{{label}\,{newlines} {
    printf("Carte:\n");
    yy_push_state(BOOK);
}

@{inproceedings}\{{label}\,{newlines} {
    printf("Articol la conferinta:\n");
    yy_push_state(INPROCEEDINGS);
}

@{other_recording}\{{label}\,{newlines} {
    // Am gasit alta inregistrare => punem pe stiva
    // starea care se ocupa cu ignorarea ei.
    yy_push_state(OTHER_RECORDINGS); 
}

<OTHER_RECORDINGS>{line}{newline}+ { /*Ignoram fiecare linie*/ }

<OTHER_RECORDINGS>(\}|{numerical}+)(""|\,){newlines}{whitespace}*\} { 
    // Am ajuns la finalul inregistrarii => scoatem starea
    // curenta de pe stiva.
    yy_pop_state(); 
}


{title} {
    // Am gasit campul "title" => printam un mesaj corespunzator
    // dupa care punem pe stiva starea "EXTRACT_INFO_TITLE".
    printf("\tTitlu: ");
    yy_push_state(EXTRACT_INFO_TITLE);
}

{author} {
    // Am gasit campul "author" => printam un mesaj corespunzator
    // dupa care punem pe stiva starea "EXTRACT_INFO"
    // La fel si pentru restul campurilor din enunt.
    printf("\tAutor:");
    yy_push_state(AUTHOR);
}

{journal} {
    printf("\tRevista: ");
    yy_push_state(EXTRACT_INFO);
}

<ARTICLE>{booktitle} {
    printf("\tCarte: ");
    yy_push_state(EXTRACT_INFO);
}

<BOOK>{booktitle} {
    printf("\tCarte: ");
    yy_push_state(EXTRACT_INFO);
}

<INPROCEEDINGS>{booktitle} {
    printf("\tConferinta: ");
    yy_push_state(EXTRACT_INFO);
}

{year} {
    printf("\tAnul publicarii: ");
    yy_push_state(EXTRACT_INFO);
}

{doi} {
    printf("\tDOI: ");
    yy_push_state(EXTRACT_INFO);
}

{organization} {
    printf("\tOrganizatie: ");
    yy_push_state(EXTRACT_INFO);
}

{number} {
    printf("\tNumar versiune: ");
    yy_push_state(EXTRACT_INFO);
}

{pages} {
    printf("\tPagini: ");
    yy_push_state(PAGES);
    // yy_push_state(EXTRACT_INFO);
}

{volume} {
    printf("\tVolum: ");
    yy_push_state(EXTRACT_INFO);
}

{publisher} {
    printf("\tEditura: ");
    yy_push_state(EXTRACT_INFO);
}

{other_field} {
    // Am gasit un camp diferit de cele din enunt => il ignoram
    // si punem pe stiva starea "IGNORE_OTHER_FIELDS".
    yy_push_state(IGNORE_OTHER_FIELDS); 
}

<IGNORE_OTHER_FIELDS>{numerical}+(""|\,){newlines}|\{{value}\}(""|\,){newlines} {
    // Ignoram in totalitate campul curent(tot ce se afla intre "{"
    // si "}", plus "\n"-urile ce ar putea fi), dupa care scoatem
    // starea de pe stiva.
    yy_pop_state(); 
}

<AUTHOR>[A-Z][a-zA-Z0-9\.\'\-\`\’]*\, {
    yytext[yyleng - 1] = '\0';
    strcpy(author_surname, yytext);
}

<AUTHOR>[A-Z][a-zA-Z0-9\.\'\-\`\’]* {
    strcat(author_name, yytext);
    strcat(author_name, " ");
}

<AUTHOR>[\n]*{whitespace}+"and"{whitespace}+ {
    strcat(author_name, author_surname);
    printf("%s,", author_name);
    
    author_name[0] = '\0';
    author_surname[0] = '\0';
    
    yy_pop_state();
    yy_push_state(AUTHOR);
}

<AUTHOR>\}(""|\,) {
    strcat(author_name, author_surname);
    printf("%s", author_name);
    author_name[0] = '\0';
    author_surname[0] = '\0';
    yy_pop_state();
}

<AUTHOR>[\n]+ { printf(" "); }

<PAGES>\{[0]* {
    yy_push_state(EXTRACT_LAST_PAGE);
}

<PAGES>"--"[0]* {
    printf("-");
    yy_push_state(LAST);
}

<EXTRACT_LAST_PAGE>[0-9]+ {
    printf("%s", yytext);
    yy_pop_state();
}

<LAST>[0-9]+\}\, {
    yytext[yyleng - 2] = '\0';
    printf("%s", yytext);
    yy_pop_state();
    yy_pop_state();
}

<LAST>[0-9]+\} {
    yytext[yyleng - 1] = '\0';
    printf("%s", yytext);
    yy_pop_state();
    yy_pop_state();
}

<EXTRACT_INFO_TITLE>\{{value}\}\, {
    // Extragem titlul inregistrarii.
    yytext[yyleng - 2] = '\0';
    printf("\"%s\"", yytext + 1);
    yy_pop_state();
}

<EXTRACT_INFO>\{{value}\}\, {
    // Extragem "valoarea" inregistrarii.
    // Similar si pentru formatul numerelor.
    yytext[yyleng - 2] = '\0';
    printf("%s", yytext + 1);
    yy_pop_state();
}

<EXTRACT_INFO>{numerical}+\, {
    yytext[yyleng - 1] = '\0';
    printf("%s", yytext);
    yy_pop_state();
}

<EXTRACT_INFO>(\{{value}\}|{numerical}+){newlines}\} {
    // Extragem ultima "valoare", dupa care scoatem ultimele
    // 2 stari salvate pe stiva(am terminat inregistrarea).
    yytext[yyleng - 3] = '\0';
    printf("%s\n", yytext + 1);
    yy_pop_state();
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

    // author_name[0] = '\0';

    yylex();
    fclose(yyin);
}