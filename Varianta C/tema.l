%option stack

%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "map.h"

FILE *out_file;

int class_count = 0;
int variable = 0;

// Numarul de paranteze al metodei "main".
int brace_count = 0;

// Numarul de clase publice.
int public_count = 0;

// Numarul de paranteze al unei clase.
int class_braces = 0;

// Liste folosite pentru numararea numarului de metode "get" si "set" ce ar
// trebui implementate(in functie de cate campuri private exista).
int get_no[1000];
int set_no[1000];

// Dictionar in care se salveaza numele claselor impreuna cu numarul de instante
// create pentru fiecare.
HashMap classes_map;

// Dictionar folosit pentru memorarea numarului de obiecte alocate in cazul array-
// urilor pentru clasele noastre.
HashMap allocations;

// Dictionar in care salvez campurile private din fiecare clasa sub forma:
// "Nume_clasa nume_camp", pentru a stii in ce clasa se afla fiecare.
HashMap classes_fields[1000];

// Dictionar in care salvez numarul de metode "get" implementate pentru fiecare clasa.
HashMap get_map;

// Analog, dar pentru "set".
HashMap set_map;

// Dictionar folosit sa retin pe langa "Nume_clasa nume_camp" si tipul de date al campului
// pentru a putea verifica daca metoda de "get" intoarce tipul corect.
HashMap types[1000];

// Numele claselor.
char classes[255][255];

// Variabila auxiliara pentru retinerea tipului de date al unei variabile sau camp.
char data_type[255];

// Variabila auxiliara pentru retinerea numelui unei variabile sau camp.
char variable_name[255];
char combination[255];

// Variabila folosita pentru retinerea mesajului ce trebuie afisat la final in functie
// de numarul de metode "get" si "set" implementate.
char getters_setters[255][1001];
char type[255];
char return_type[255];
%}

%s MAIN
%s FIELDS
%s EXTRACT_NAME
%s GET_NAME
%s SET_NAME
%s OBJECT OBJECT_ARRAY CHECK_TYPE FIND_ALLOCATIONS
%s ARRAY_INSTANCE

ALPHA_NUMERICAL [a-zA-Z0-9]
whitespace [ ]
wrappers ("String"|"Integer"|"Float"|"Long"|"Double"|"Boolean"|"Short"|"Character"|"Byte")(""|\[\]){whitespace}+{ALPHA_NUMERICAL}+{whitespace}*\={whitespace}*"new"{whitespace}+{ALPHA_NUMERICAL}+

public_class "public class "
class "class"{whitespace}+
private_field "private"{whitespace}+
setter "public"{whitespace}+"void"{whitespace}+"set"
getter "public"{whitespace}+{ALPHA_NUMERICAL}+(""|\[\]){whitespace}+"get"
setName {ALPHA_NUMERICAL}+
getName {ALPHA_NUMERICAL}+
main "public static void main(String[] args)"
main_array_allocation {ALPHA_NUMERICAL}+\[\]
name {ALPHA_NUMERICAL}+
allocation "new"[ ]+{ALPHA_NUMERICAL}+
number_of_allocations \[[0-9]+\]\;
simple_instantiation {ALPHA_NUMERICAL}+[ ]+{ALPHA_NUMERICAL}+[ ]*\=[ ]*"new"[ ]+{ALPHA_NUMERICAL}+\(
array_instantiation {ALPHA_NUMERICAL}+\[[a-zA-Z]
instances_found "new"[ ]+{ALPHA_NUMERICAL}+\(

%%

"//"[^\n]* { }

{public_class}{ALPHA_NUMERICAL}+ {
    // Daca gasesc o clasa publica, ii salvez numele in
    // lista de clase(la fel si pentru o clasa normala).
    strcpy(classes[class_count], yytext + 13);
    
    // In cazul in care dictionarul de clase nu contine clasa gasita, adaugam
    // o noua intrare in acesta, cheia fiind numele clasei, iar valoarea 0
    // (nu exista nicio instanta momentan).
    if (contains(&classes_map, classes[class_count]) == 0) {
        put(&classes_map, classes[class_count], 0);
    }

    // Adaug in dictionarele pentru "get" si "set" numele clasei impreuna cu
    // valoarea 0(n-am gasit inca nicio metoda de "get" sau "set").
    put(&get_map, classes[class_count], 0);
    put(&set_map, classes[class_count], 0);
    
    // Incrementez numarul de aparitii pentru clase publice.
    public_count++;
    
    // Dupa ce am terminat, intru in interiorul clasei pentru a analiza campurile.
    yy_push_state(FIELDS);
}

{class}{ALPHA_NUMERICAL}+ {
    // Analog cu regula pentru clase publice(fara incrementare).
    strcpy(classes[class_count], yytext + 6);
    
    if (contains(&classes_map, classes[class_count]) == 0) {
        put(&classes_map, classes[class_count], 0);
    }
    
    put(&get_map, classes[class_count], 0);
    put(&set_map, classes[class_count], 0);
    
    yy_push_state(FIELDS);
}

<FIELDS>\{ {
    // Am gasit o acolada deschisa, deci cresc numarul acestora. 
    class_braces++;
}

<FIELDS>\} {
    // Am gasit o acolada inchisa, deci decrementez numarul acestora.
    class_braces--;

    // In cazul in care numarul de paranteze ale clase a ajuns la 0, inseamna
    // ca trebuie sa vad daca metodele de "get" si "set" au fost implementate
    // complet, partial sau deloc. Dupa completarea string-ului "getters_setters",
    // continui prin incrementarea numarului de clase(noul index al celei ce urmeaza)
    // extragerea starii respective de pe stiva(pentru a incepe o noua clasa).
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

<FIELDS>{private_field}{ALPHA_NUMERICAL}+(""|\[\]) {
    // Daca gasesc un camp privat, retin intr-o variabila tipul de date
    // al acesteia in prima faza, dupa care continui analiza prin adaugarea
    // pe stiva a unei stari responsabile cu extragerea numelui campului.
    strcpy(type, yytext + 8);
    yy_push_state(EXTRACT_NAME);
}

<EXTRACT_NAME>{ALPHA_NUMERICAL}+[ ]* {
    char combine[255];
    
    // Retinem intr-o variabila clasa in care se afla campul si numele acestuia.
    strcpy(combine, classes[class_count]);
    strcat(combine, " ");
    strcat(combine, yytext);

    // Retinem pe langa tip, numele clasei in care campul se afla si numele acestuia
    strcat(type, " ");
    strcat(type, combine);

    // In dictionarul pentru tipuri punem valoarea obtinuta a lui "type", iar in cel
    // ce contine campurile clasei, punem valoarea lui "combine"
    put(&types[class_count], type, 1);
    put(&classes_fields[class_count], combine, 1);

    // Incrementez numarul de metode "get" si "set" ce ar trebui implementate.
    get_no[class_count]++;
    set_no[class_count]++;

    type[0] = '\0';

    // Scot starea din stiva pentru a gasii o alta potrivire.
    yy_pop_state();
}

<FIELDS>{setter} {
    // In cazul unei metode de "set", pun pe stiva starea "SET_NAME", responsabila
    // pentru extragerea numelui acesteia.
    yy_push_state(SET_NAME);
}

<SET_NAME>{setName} {
    char name[255];

    // Extrag numele aflat dupa "set", dupa care prima litera o fac mica, deoarece in
    // mod normal aceasta ar trebui sa fie mare.
    strcpy(name, yytext);
    name[0] = tolower(name[0]);

    // Daca exista campul respectiv in clasa, atunci incrementez numarul de metode "set"
    // implementate pentru clasa respectiva.
    if (contains(&classes_fields[class_count], name) == 1) {
        put(&set_map, classes[class_count], getValue(&set_map, classes[class_count]) + 1);
    }

    // Scot starea din stiva si caut o alta potrivire.
    yy_pop_state();
}

<FIELDS>{getter} {
    // Scot ultimele 4 caractere, corespunzatoare lui " get".
    yytext[yyleng - 4] = '\0';

    // Extrag doar tipul de retur al metodei, prin ignorarea lui "public " si salvez in
    // "return_type" tipul de date returnat, impreuna cu numele clasei in care ma aflu.
    strcpy(return_type, yytext + 7);
    strcat(return_type, " ");
    strcat(return_type, classes[class_count]);

    // Trec la urmatoarea stare responsabila pentru extragerea numelui metodei de dupa
    // "get".
    yy_push_state(GET_NAME);
}

<GET_NAME>{getName}+ {
    char name[255];

    // La fel ca la "set"
    strcpy(name, yytext);
    name[0] = tolower(name[0]);
    
    strcat(return_type, " ");
    strcat(return_type, name);

    // doar ca de data aceasta am grija sa ma asigur de faptul ca tipul de date returnat de metoda este acelasi
    // cu cel pe care il are campul corespunzator din clasa, caz in care incrementez numarul de metode "get"
    // implementate.
    if (contains(&classes_fields[class_count], name) == 1 && contains(&types[class_count], return_type) == 1) {
        put(&get_map, classes[class_count], getValue(&get_map, classes[class_count]) + 1);
    }

    return_type[0] = '\0';

    // Trec la alta stare.
    yy_pop_state();
}

{main} {
    // Daca am gasit metoda "main", intram in aceasta.
    yy_push_state(MAIN);
}

<MAIN>\{ {
    // La fel ca la clase.
    brace_count++;
}

<MAIN>\} {
    // La fel ca la clase.
    brace_count--;
    if(brace_count == 0) {
        yy_pop_state();
    }
}

<MAIN>{wrappers} {
    // Ignoram orice clasa "wrapper" predefinita deja in limbaj.
}

<MAIN>{main_array_allocation} {
    // Am gasit o alocare pentru unu array de obiecte corespuznatoare
    // claselor create in program, deci salvam tipul de date.
    yytext[yyleng - 2] = '\0';

    strcpy(data_type, yytext);    
    strcpy(combination, data_type);
    strcat(combination, " ");

    // Trecem la urmatoarea stare, responsabila cu extragerea numelui.
    yy_push_state(OBJECT_ARRAY);
}

<OBJECT_ARRAY>{name} {
    // Extragem numele array-ului.
    strcpy(variable_name, yytext);
    strcat(combination, variable_name);
    
    // Trecem la starea de verificare.
    yy_push_state(CHECK_TYPE);
}

<CHECK_TYPE>{allocation} {
    char type_aux[255];
    // Salvam tipul de date de dupa "new ".
    strcpy(type_aux, yytext + 4);

    // Daca acesta contine, pe langa cateva spatii in plus posibile,
    // tipul de date initial de la care am plecat(Tip[] nume = new Tip[nr]),
    // atunci trecem la starea urmatoare. In caz contrar, ne oprim aici si
    // scoatem ultimele 2 stari adaugate pe stiva.
    if (strstr(type_aux, data_type)) {
        yy_push_state(FIND_ALLOCATIONS);
    } else {
        combination[0] = '\0';
        data_type[0] = '\0';
        variable_name[0] = '\0';
        yy_pop_state();
        yy_pop_state();
    }
}

<FIND_ALLOCATIONS>{number_of_allocations} {
    char num[255];
    // Extragem numarul de alocari dintre paranteze si ii dam convert folosind "atoi".
    yytext[yyleng - 2] = '\0';
    
    strcpy(num, yytext + 1);
    variable = atoi(num);

    // Punem in dictionarul cu alocari, variabila ce contine tipul de date si numele variabilei
    // pentru care s-a facut alocarea respectiva.
    if (contains(&classes_map, data_type) == 0) {
        put(&allocations, combination, variable + 1);
    } else {
        put(&allocations, combination, variable);
    }

    combination[0] = '\0';
    data_type[0] = '\0';
    variable_name[0] = '\0';
    variable = 0;

    // Am terminat analiza alocarii, deci putem scoate toate cele 3 stari de pe stiva.
    yy_pop_state();
    yy_pop_state();
    yy_pop_state();
}

<MAIN>{simple_instantiation} {
    // In cazul unei instantieri directe, extrag fiecare cuvant.
    char *type_left = strtok(yytext, " =(");
    strtok(NULL, " =(");
    strtok(NULL, " =(");
    char *type_right = strtok(NULL, " =(");
    
    // Verific daca tipul de date de pe stanga este acelasi cu cel de pe dreapta si daca
    // exista tipul acesta de date in dictionarul pentru instantele claselor, caz in care
    // incrementez numarul de instante pentru clasa respectiva.
    if (contains(&classes_map, type_left) == 1 && strcmp(type_left, type_right) == 0) {
        put(&classes_map, type_left, getValue(&classes_map, type_left) + 1);
    } else if (contains(&classes_map, type_left) == 0 && strcmp(type_left, type_right) == 0) {
        // Daca nu exista, este adaugata in dictionar.
        put(&classes_map, type_left, 1);
    }
}

<MAIN>{array_instantiation} {
    // In cazul unei instantieri pentru array, retin numele array-ului si trec
    // mai depare la starea responsabila cu gestionarea numarului de instante.
    yytext[yyleng - 2] = '\0';
    strcpy(variable_name, yytext);
    
    if (contains(&allocations, variable_name) == 1) {
        yy_push_state(ARRAY_INSTANCE);
    }
}

<ARRAY_INSTANCE>{instances_found} {
    // Salvez tipul de date de dupa "new ".
    char type_aux[255];
    yytext[yyleng - 1] = '\0';
    strcpy(type_aux, yytext + 4);

    // Extragem numarul de alocari in functie de numele array-ului.
    int x = getValue(&allocations, variable_name);

    // In cazul in care gasim numele in dictionarul cu alocari cautam cheia ce contine
    // acest nume, pentru care extragem doar primul cuvant, acesta reprezentand tipul
    // de date(clasa). Verificam sa avem acelasi tip de date si adaugam in dictionarul
    // pentru instantieri clasa impreuna cu noua valoare.
    if (contains(&allocations, variable_name) == 1) {
        char *key = getKeyByWord(&allocations, variable_name);
        char *class = strtok(key, " ");
        printf("\"%s\"", class);
        
        if (strstr(type_aux, class)) {
            put(&classes_map, class, getValue(&classes_map, class) + x);
        }
    }

    variable_name[0] = '\0';

    // Am terminat partea cu instantierile.
    yy_pop_state();
}

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) 
{
    if (argc != 3) {
        fprintf(stderr, "Argument required!\n");
        exit(1);
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error opening file: %s\n", argv[1]);
        exit(1);
    }

    out_file = fopen(argv[2], "w");
    if (!out_file) {
        fprintf(stderr, "Error opening output file: file.out\n");
        exit(1);
    }

    yylex();
    printf("\n");

    // Salvez intr-un fisier output-ul
    fprintf(out_file, "Clase %d: ", class_count);

    for (int i = 0; i < class_count - 1; i++) {
        fprintf(out_file, "%s, ", classes[i]);
    }

    fprintf(out_file, "%s\n\n", classes[class_count - 1]);

    // Pentru mai mult de 2 clase publice printez un mesaj de eroare.
    if (public_count >= 2) {
        fprintf(out_file, "ERROR: cannot have two public classes in the same file!\n");
    } else {
        for (int i = 0; i < class_count; i++) {
            fprintf(out_file, "Obiecte %s: %d\n", classes[i], getValue(&classes_map, classes[i]));
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