%option stack

%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "map.h"

FILE *out_file;

int class_count = 0;
int variable = 0;
int in_main = 0;
int brace_count = 0;
int public_count = 0;
int class_braces = 0;

int get_no[1000];
int set_no[1000];

HashMap classes_map;
HashMap allocations;
HashMap classes_fields[1000];
HashMap get_map;
HashMap set_map;

char classes[255][255];
char class_name[255];
char data_type[255];
char variable_name[255];
char combination[255];
char aux[255];
%}

%s MAIN
%s FIELDS

%%

"//"[^\n]* { }

(""|"public")"class"[ ]+[a-zA-Z0-9]+ {
    printf("%s", yytext);
    sscanf(yytext + 5, " %[a-zA-Z0-9]+", classes[class_count]);
    put(&classes_map, classes[class_count], 0);
    put(&get_map, classes[class_count], 0);
    put(&set_map, classes[class_count], 0);
    yy_push_state(FIELDS);
}

<FIELDS>\{ {
    printf("%s", yytext);
    class_braces++;
}

<FIELDS>\} {
    printf("%s", yytext);
    class_braces--;
    if (class_braces == 0) {
        class_count++;
        fprintf(out_file, "%s:\n", classes[class_count - 1]);
        if (get_no[class_count - 1] == 0 && set_no[class_count - 1] == 0) {
            fprintf(out_file, "\t-> Nu exista atribute private.\n");
        }
        else if (get_no[class_count - 1] == getValue(&get_map, classes[class_count - 1]) && set_no[class_count - 1] == getValue(&set_map, classes[class_count - 1])) {
            fprintf(out_file, "\t-> \"get\" si \"set\" sunt implementate.\n");
        }
        else if (get_no[class_count - 1] > getValue(&get_map, classes[class_count - 1]) && set_no[class_count - 1] > getValue(&set_map, classes[class_count - 1])) {
            fprintf(out_file, "\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n");
            fprintf(out_file, "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
        }
        else if (get_no[class_count - 1] == getValue(&get_map, classes[class_count - 1]) && set_no[class_count - 1] > getValue(&set_map, classes[class_count - 1])) {
            fprintf(out_file, "\t-> Metoda \"get\" este implementata;\n");
            fprintf(out_file, "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
        }
        else if (get_no[class_count - 1] > getValue(&get_map, classes[class_count - 1]) && set_no[class_count - 1] == getValue(&set_map, classes[class_count - 1])) {
            fprintf(out_file, "\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n");
            fprintf(out_file, "\t-> Metoda \"set\" este implementata.\n");
        }
        yy_pop_state();
    }
}

<FIELDS>"private"[ ]+[a-zA-Z0-9]+(""|\[\])[ ]+[a-zA-Z0-9]+[ ]* {
    printf("%s", yytext);
    char name[255];
    char name1[255];
    if (in_main == 0) {
        sscanf(yytext, "private %s %s", name1, name);
        printf("\"%s\"", name);
        char combine[255];
        strcpy(combine, classes[class_count]);
        strcat(combine, " ");
        strcat(combine, name);
        put(&classes_fields[class_count], combine, 1);
        get_no[class_count]++;
        set_no[class_count]++;
    }
}

<FIELDS>"public"[ ]+[a-zA-Z0-9]+[ ]+"get"[a-zA-Z0-9]+ {
    char name[255];
    char name1[255];
    sscanf(yytext, "public %s get%s", name1, name);
    name[0] = tolower(name[0]);
    printf("\"%s\"", name);

    if (contains(&classes_fields[class_count], name) == 1) {
        put(&get_map, classes[class_count], getValue(&get_map, classes[class_count]) + 1);
        printf("Class: \"%s\", Getters: \"%d\"", classes[class_count], getValue(&get_map, classes[class_count]));
    } else {
        put(&get_map, classes[class_count], 1);
    }
}

<FIELDS>"public void set"[a-zA-Z0-9]+ {
    char name[255];
    sscanf(yytext, "public void set%[a-zA-Z0-9]+", name);
    name[0] = tolower(name[0]);
    printf("\"%s\"", name);

    if (contains(&classes_fields[class_count], name) == 1) {
        put(&set_map, classes[class_count], getValue(&set_map, classes[class_count]) + 1);
        printf("Class: \"%s\", Setters: \"%d\"", classes[class_count], getValue(&set_map, classes[class_count]));
    } else {
        put(&set_map, classes[class_count], 1);
    }
}

"public static void main(String[] args)" {
    printf("%s", yytext);
    in_main = 1;
    yy_push_state(MAIN);
}

<MAIN>\{ {
    printf("%s", yytext);
    if (in_main == 1) {
        brace_count++;
    }
}

<MAIN>\} {
    printf("%s", yytext);
    if(in_main == 1) {
        --brace_count;
        if(brace_count == 0) {
            in_main = 0;
            yy_pop_state();
        }
    }
}

<MAIN>[ \t]*[a-zA-Z0-9]+[\[\] ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+\[[0-9]+\]\; {
    printf("%s", yytext);

    sscanf(yytext, " %[a-zA-Z0-9][] %s", data_type, variable_name);
    sscanf(yytext, "%*[^0123456789]%d", &variable);
    
    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);

    put(&allocations, combination, variable);
}

<MAIN>[ \t]*[a-zA-Z0-9]+[ ]+[a-zA-Z0-9]+[ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+ {
    printf("%s", yytext);

    sscanf(yytext, " %[a-zA-Z0-9] %s", data_type, variable_name);

    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);

    if (getValue(&allocations, combination) == -1) {
        put(&allocations, combination, 1);
    } else {
        put(&allocations, combination, getValue(&allocations, combination) + 1);
    }

    if (contains(&classes_map, data_type) == 0) {
        put(&classes_map, data_type, 1);
    } else {
        put(&classes_map, data_type, getValue(&classes_map, data_type) + 1);
    }
}

<MAIN>[ \t]*[a-zA-Z0-9]+\[[a-zA-Z0-9]+\][ ]*\=[ ]*"new"[ ]+[a-zA-Z0-9]+  {
    printf("%s", yytext);
    char name[255];
    sscanf(yytext, " %[a-zA-Z0-9]+[[a-zA-Z0-9]+][ ]*=", name);
    int x = getValue(&allocations, name);
    if (contains(&allocations, name) == 1) {
        char *key = getKeyByWord(&allocations, name);
        char *class = strtok(key, " ");
        put(&classes_map, class, getValue(&classes_map, class) + x);
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

    if (public_count >= 2) {

    } else {
        fprintf(out_file, "Clase %d: ", class_count);

        for (int i = 0; i < class_count - 1; i++) {
            fprintf(out_file, "%s, ", classes[i]);
        }

        fprintf(out_file, "%s\n\n", classes[class_count - 1]);

        //printHashMap(&classes_map);
        printf("\nFields:\n");

        for (int i = 0; i < class_count; i++) {
            printHashMap(&classes_fields[i]);
        }

        printf("\nSet map:\n\n");
        printHashMap(&set_map);
        printf("\nGet map:\n\n");
        printHashMap(&get_map);
        printf("\n\n");

        for (int i = 0; i < class_count; i++) {
            fprintf(out_file, "Obiect %s: %d\n", classes[i], getValue(&classes_map, classes[i]));
        }

        fprintf(out_file, "\n");
        
        printf("\n");

        for (int i = 0; i < class_count; i++) {
            printf("Class %s has %d private members\n", classes[i], get_no[i]);
        }

        for (int i = 0; i < class_count; i++) {
            fprintf(out_file, "%s:\n", classes[i]);

            if (get_no[i] == 0 && set_no[i] == 0) {
                fprintf(out_file, "\t-> Nu exista atribute private.\n");
            }
            else if (get_no[i] == getValue(&get_map, classes[i]) && set_no[i] == getValue(&set_map, classes[i])) {
                fprintf(out_file, "\t-> \"get\" si \"set\" sunt implementate.\n");
            }
            else if (get_no[i] > getValue(&get_map, classes[i]) && set_no[i] > getValue(&set_map, classes[i])) {
                fprintf(out_file, "\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n");
                fprintf(out_file, "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
            }
            else if (get_no[i] == getValue(&get_map, classes[i]) && set_no[i] > getValue(&set_map, classes[i])) {
                fprintf(out_file, "\t-> Metoda \"get\" este implementata;\n");
                fprintf(out_file, "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
            }
            else if (get_no[i] > getValue(&get_map, classes[i]) && set_no[i] == getValue(&set_map, classes[i])) {
                fprintf(out_file, "\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n");
                fprintf(out_file, "\t-> Metoda \"set\" este implementata.\n");
            }
        }
    }

    fclose(yyin);
    fclose(out_file);

    return 0;
}