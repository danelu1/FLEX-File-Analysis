%{
#include <stdio.h>
%}

%s NEXT
%s NEXT1
%s NEXT2
%s IGNORE_BRACKET_COMMA
%s IGNORE_NON_FIELDS
%s NEXT_STATE

%%

"%"[^\n]*[\n{1,}]|"%"[^\n]* { }
"=" { }
\{[a-zA-Z0-9]*\,\n { }
\{|\} { }
\},[\n{1,}]|\,[\n{1,}]|\}[\n{1, }] { printf("\n"); }
\n{2,} { }

@[aA][rR][tT][iI][cC][lL][eE] { printf("Articol in revista:\n"); }

@[bB][oO][oO][kK] { printf("Carte:\n"); }

@[iI][nN][pP][rR][oO][cC][eE][eE][dD][iI][nN][gG][sS] { printf("Articol la conferinta:\n"); }

"title"[ ]*\=[ ]*\{ { printf("\tTitlu: "); BEGIN (NEXT); }

"author"[ ]*\=[ ]*\{ { printf("\tAutori: "); BEGIN (NEXT1); }

"journal"[ ]*\=[ ]*\{|[ ]*\= { printf("\tRevista: "); BEGIN (NEXT1); }

"year"[ ]*\=[ ]*\{ { printf("\tAn: "); BEGIN (NEXT1); }

"year"[ ]*\=[ ]* { printf("\tAn: "); BEGIN(NEXT2); }

"volume"[ ]*\=[ ]*\{ { printf("\tVolum: "); BEGIN (NEXT1); }

"volume"[ ]*\=[ ]* { printf("\tVolum: "); BEGIN (NEXT2); }

"publisher"[ ]*\=[ ]*\{ { printf("\tEditura: "); BEGIN (NEXT1); }

"number"[ ]*\=[ ]*\{ { printf("\tVersiune: "); BEGIN (NEXT1); }

"number"[ ]*\=[ ]* { printf("\tVersiune: "); BEGIN (NEXT2); }

"pages"[ ]*\=[ ]*\{ { printf("\tPagini resursa: "); BEGIN (NEXT1); }

"doi"[ ]*\=[ ]*\{ { printf("\tDOI: "); BEGIN (NEXT1); }

"booktitle"[ ]*\=[ ]*\{ { printf("\tTitlu revista: "); BEGIN (NEXT1); }

"organization"[ ]*\=[ ]*\{ { printf("\tOrganizatie: "); BEGIN (NEXT1); }

<NEXT>[^}]+ { printf("\"%s\"", yytext); BEGIN (IGNORE_BRACKET_COMMA); }

<NEXT1>[^}]+ { printf("%s", yytext); BEGIN (IGNORE_BRACKET_COMMA); }

<NEXT2>[^\,]+ { printf("%s", yytext); BEGIN (IGNORE_BRACKET_COMMA); }

<IGNORE_BRACKET_COMMA>\, { printf("%s", yytext + 1); }

[a-zA-Z]+[ ]*\=[ ]*\{ { BEGIN (IGNORE_NON_FIELDS); }
[a-zA-Z]+[ ]*\=[ ]* { BEGIN (IGNORE_NON_FIELDS); }

<IGNORE_NON_FIELDS>[^}] { }

@[a-zA-Z]+ { }

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
