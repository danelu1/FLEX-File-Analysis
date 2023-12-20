%option stack

%{
#include <stdio.h>
#include <stdlib.h>
#include "map.h"

FILE *out_file;

int class_count = 0;
int variable = 0;
int in_main = 0;

HashMap classes_map;
HashMap allocations;

char classes[255][255];
char class_name[255];
char data_type[255];
char variable_name[255];
char combination[255];
char aux[255];
%}

%s FIND_INSTANCES
%s MAIN

%%

"//"[^\n]* { }

(""|"public")"class"[ ]+[a-zA-Z0-9]+ {
    sscanf(yytext + 5, " %[a-zA-Z0-9]+", classes[class_count]);
    put(&classes_map, classes[class_count], 0);
    class_count++;
}

"public static void main(String[] args)"[ ]*\{ {
    printf("%s", yytext);
}

[ \t]*("int"|"float"|"long"|"double"|"char"|"byte"|"short"|"boolean")\[\][ ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+("int"|"float"|"long"|"double"|"char"|"byte"|"short"|"boolean")\[[0-9]+\] { }
[ \t]*("Integer"|"Float"|"Long"|"Double"|"Character"|"Byte"|"Short"|"Boolean"|"String")\[\][ ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+("Integer"|"Float"|"Long"|"Double"|"Character"|"Byte"|"Short"|"Boolean"|"String")\[[0-9]+\] { }

("private"|"public"|"")[ ]+("int"|"float"|"long"|"double"|"char"|"byte"|"short"|"boolean")("[]"|"")[ ]+[a-zA-Z0-9]+[ ]+\= { }
("private"|"public"|"")[ ]+("Integer"|"Float"|"Long"|"Double"|"Character"|"Byte"|"Short"|"Boolean"|"String")("[]"|"")[ ]+[a-zA-Z0-9]+[ ]+\= { }

[ \t]*[a-zA-Z0-9]+[\[\] ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+\[[0-9]+\]\; {
    sscanf(yytext, " %[a-zA-Z0-9][] %s", data_type, variable_name);
    sscanf(yytext, "%*[^0123456789]%d", &variable);

    printf("\"%s\"", data_type);
    printf("\"%s\"", variable_name);
    printf("\"%d\"", variable);
    
    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);
    printf("\"%s\"", combination);
    put(&allocations, combination, variable);

    yy_push_state(FIND_INSTANCES);
}

[ \t]*[a-zA-Z0-9]+[ ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+ {
    sscanf(yytext, " %[a-zA-Z0-9] %s", data_type, variable_name);
    printf("\"%s\"", data_type);
    printf("\"%s\"", variable_name);

    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);
    printf("\"%s\"", combination);

    if (getValue(&allocations, combination) == -1) {
        put(&allocations, combination, 1);
    } else {
        put(&allocations, combination, getValue(&allocations, combination) + 1);
    }

    if (getValue(&classes_map, data_type) == -1) {
        put(&classes_map, data_type, 1);
        //printf("\"%d\"", getValue(&classes_map, data_type));
    } else {
        put(&classes_map, data_type, getValue(&classes_map, data_type) + 1);
        //printf("\"%s\": \"%d\"", data_type, getValue(&classes_map, data_type));
    }
}

<FIND_INSTANCES>[ \t]*[a-zA-Z0-9]+\[[a-zA-Z0-9]+\][ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+  {
    char name[255];
    sscanf(yytext, " %[a-zA-Z0-9]+[[a-zA-Z0-9]+][ ]*=", name);
    printf("\"%s\"", name);
    int x = getValue(&allocations, name);
    if (contains(&allocations, name) == 1) {
        char *key = getKeyByWord(&allocations, name);
        char *class = strtok(key, " ");
        put(&classes_map, class, getValue(&classes_map, class) + x);
        yy_pop_state();
    } else {
        REJECT;
    }
}

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) 
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s input_file\n", argv[0]);
        exit(1);
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error opening file: %s\n", argv[1]);
        exit(1);
    }

    out_file = fopen("f.out", "w");
    if (!out_file) {
        fprintf(stderr, "Error opening output file: f.out\n");
        exit(1);
    }

    yylex();
    printf("\n");

    fprintf(out_file, "Clase %d: ", class_count);

    for (int i = 0; i < class_count - 1; i++) {
        fprintf(out_file, "%s, ", classes[i]);
    }

    fprintf(out_file, "%s\n\n", classes[class_count - 1]);

    printHashMap(&classes_map);
    printf("\nAllocations:\n");
    printHashMap(&allocations);

    for (int i = 0; i < class_count; i++) {
        fprintf(out_file, "Obiect %s: %d\n", classes[i], getValue(&classes_map, classes[i]));
    }

    fclose(yyin);
    fclose(out_file);

    return 0;
}