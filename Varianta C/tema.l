%option stack

%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "map.h"

FILE *out_file;

int class_count = 0;
int variable = 0;
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
char data_type[255];
char variable_name[255];
char combination[255];
char instances_output[255][1001];
char getters_setters[255][1001];
%}

%s MAIN
%s FIELDS
ALPHA_NUMERICAL [a-zA-Z0-9]

%%

"//"[^\n]* { }

(""|"public")"class"[ ]+{ALPHA_NUMERICAL}+ {
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
        if (get_no[class_count] == 0 && set_no[class_count] == 0) {
            sprintf(getters_setters[class_count], "%s:\n\t-> Nu exista atribute private.\n", classes[class_count]);
        }
        else if (get_no[class_count] == getValue(&get_map, classes[class_count]) && set_no[class_count] == getValue(&set_map, classes[class_count])) {
            sprintf(getters_setters[class_count], "%s:\n\t-> \"get\" si \"set\" sunt implementate.\n", classes[class_count]);
        }
        else if (get_no[class_count] > getValue(&get_map, classes[class_count]) && set_no[class_count] > getValue(&set_map, classes[class_count])) {
            sprintf(getters_setters[class_count], "%s:\n\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n", classes[class_count]);
            strcat(getters_setters[class_count], "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
        }
        else if (get_no[class_count] == getValue(&get_map, classes[class_count]) && set_no[class_count] > getValue(&set_map, classes[class_count])) {
            sprintf(getters_setters[class_count], "%s:\n\t-> Metoda \"get\" este implementata;\n", classes[class_count]);
            strcat(getters_setters[class_count], "\t-> Metoda \"set\" nu este implementata pentru toate atributele.\n");
        }
        else if (get_no[class_count] > getValue(&get_map, classes[class_count]) && set_no[class_count] == getValue(&set_map, classes[class_count])) {
            sprintf(getters_setters[class_count], "%s:\n\t-> Metoda \"get\" nu este implementata pentru toate atributele;\n", classes[class_count]);
            strcat(getters_setters[class_count], "\t-> Metoda \"set\" este implementata.\n");
        }

        class_count++;
        yy_pop_state();
    }
}

<FIELDS>"private"[ ]+{ALPHA_NUMERICAL}+(""|\[\])[ ]+{ALPHA_NUMERICAL}+[ ]* {
    printf("%s", yytext);
    char name[255];
    char name1[255];
    sscanf(yytext, "private %s %s", name1, name);
    char combine[255];
    strcpy(combine, classes[class_count]);
    strcat(combine, " ");
    strcat(combine, name);
    put(&classes_fields[class_count], combine, 1);
    get_no[class_count]++;
    set_no[class_count]++;
}

<FIELDS>"public"[ ]+{ALPHA_NUMERICAL}+[ ]+"get"{ALPHA_NUMERICAL}+ {
    char name[255];
    char name1[255];
    sscanf(yytext, "public %s get%s", name1, name);
    name[0] = tolower(name[0]);
    printf("\"%s\"", name);

    if (contains(&classes_fields[class_count], name) == 1) {
        put(&get_map, classes[class_count], getValue(&get_map, classes[class_count]) + 1);
    }
}

<FIELDS>"public void set"{ALPHA_NUMERICAL}+ {
    char name[255];
    sscanf(yytext, "public void set%[a-zA-Z0-9]+", name);
    name[0] = tolower(name[0]);
    printf("\"%s\"", name);

    if (contains(&classes_fields[class_count], name) == 1) {
        put(&set_map, classes[class_count], getValue(&set_map, classes[class_count]) + 1);
    }
}

"public static void main(String[] args)" {
    printf("%s", yytext);
    yy_push_state(MAIN);
}

<MAIN>\{ {
    printf("%s", yytext);
    brace_count++;
}

<MAIN>\} {
    brace_count--;
    if(brace_count == 0) {
        printf("\"%s\"", yytext);
        for (int i = 0; i < 100; i++) {
            Node *current = classes_map.buckets[i];
            while (current != NULL)
            {
                sprintf(instances_output[i], "Obiect %s: %d\n", current->data.key, getValue(&classes_map, current->data.key));
                current = current->next;
            }
        }

        yy_pop_state();
    }
}

<MAIN>[ \t]*{ALPHA_NUMERICAL}+[\[\] ]+{ALPHA_NUMERICAL}+[ ]*\=[ ]*"new"[ ]+{ALPHA_NUMERICAL}+\[[0-9]+\]\; {
    printf("%s", yytext);

    sscanf(yytext, " %[a-zA-Z0-9][] %s", data_type, variable_name);
    sscanf(yytext, "%*[^0123456789]%d", &variable);
    
    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);

    put(&allocations, combination, variable);
}

<MAIN>[ \t]*{ALPHA_NUMERICAL}+[ ]+{ALPHA_NUMERICAL}+[ ]*\=[ ]*"new"[ ]+{ALPHA_NUMERICAL}+ {
    printf("%s", yytext);
    sscanf(yytext, " %[a-zA-Z0-9] %s", data_type, variable_name);

    strcpy(combination, data_type);
    strcat(combination, " ");
    strcat(combination, variable_name);

    if (contains(&classes_map, data_type) == 1) {
        put(&classes_map, data_type, getValue(&classes_map, data_type) + 1);
    } else {
        put(&classes_map, data_type, 1);
    }
}

<MAIN>[ \t]*{ALPHA_NUMERICAL}+\[{ALPHA_NUMERICAL}+\][ ]*\=[ ]*"new"[ ]+{ALPHA_NUMERICAL}+  {
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

    out_file = fopen("file.out", "w");
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

        for (int i = 0; i < 100; i++) {
            fprintf(out_file, "%s", instances_output[i]);
        }

        fprintf(out_file, "\n");
        
        printf("\n");

        for (int i = 0; i < class_count; i++) {
            fprintf(out_file, "%s", getters_setters[i]);
        }
    }

    fclose(yyin);
    fclose(out_file);

    return 0;
}