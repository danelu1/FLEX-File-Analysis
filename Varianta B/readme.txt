Sprincenatu Bogdan-Andrei 332CC

Am ales sa rezolv tema in "C", in "Visual Studio Code".

Pentru rezolvarea temei am considerat reguli pentru fiecare situatie posibila care poate aparea.
In prima faza am ales sa ignor comentariile, impreuna cu fiecare simbol "\n" ce putea urma la finalul liniei respective, observand
ca dupa fiecare simbol "%" poate urma, in mod optional, cel putin un caracter diferit de "\n", in continuarea caruia pot aparea oricate
linii goale(regula intitulata "comment"). Dupa ignorarea comentariilor am ales sa ignor orice aparitie a simbolurilor "{" si "}", deoarece
pe parcursul rezolvarii temei am observat ca acestea puteau aparea in urma unor cazuri netratate(pe care ulterior le-am tratat). Am ales
sa inlocuiesc oricate simboluri de "\n" consecutive(al caror numar este >= 2) cu un singur "\n" pentru a nu exista foarte multe linii intre
2 inregistrari consecutive sau 2 campuri ale unei inregistrari.

In continuare, am inceput tratarea inregistrarilor cu ajutorul unor reguli de forma: "@inregistrare{eticheta,", unde "inregistrare"
reprezinta de fapt una din cele trei tipuri posibile prezentate in enuntul temei, iar "eticheta" reprezinta textul dintre acolada si virgula
(folosit pentru citare) pe care l-am ignorat in interiorul regulilor. Pentru a tine cont ca inregistrarile sunt "case insensitive" m-am gandit
in prima faza sa parcurg textul ce face "match" pe regula mea(doar cel dintre "@" si "{") si sa aplic functia "tolower" pe fiecare caracter
in parte. O operatie de genul fiind "interzisa", am ales sa iau fiecare inregistrare in parte si sa o scriu ca o combinatie de toate
literele pentru a contoriza astfel ambele posibilitati(intalnirea unei litere atat mari cat si mici). De exemplu, pentru inregistrarile de tip
"article" am scris [aA][rR][tT][iI][cC][lL][eE]. Eticheta am considerat ca poate fi formata atat din caractere alfa numerice, cat si din
simboluri precum ', " sau -(O'Driscoll2014, Bogdan-Andrei200, etc...). Pentru fiecare regula mentionata, printez un mesaj specific, dupa care
pun pe stiva de stari din "FLEX" starea specifica fiecarui tip(am folosit stari diferite pentru printarea caracteristicilor specifice unei
anumite inregistrari, de exemplu "booktitle"). In cazul intalnirii unei inregistrari diferite de cele mentionate in enuntul temei(caz in care
folosesc o regula similara cu cele prezentate anterior, doar ca de data aceasta putem avea orice alt caracter alfa numeric, deoarece astfel
celelalte reguli, legate de tipul inregistrarii, nu vor fi "match"-uite si va ramane doar asta care indeplineste pattern-ul) vom pune pe stiva
o stare(OTHER_RECORDINGS) care se ocupa de tratarea acestuia. Avand in vedere ca trebuie ignorat fiecare caracter din interiorul inregistrarii
respective, am o regula care ignora toate liniile din interiorul inregistrarii(inclusiv "\n"-urile), aceasta terminandu-se in momentul in care
e intalnita una din regulile responsabile cu eliminarea starii din varful stivei. O inregistrare in astfel de fisiere am observat ca este
incheiata in momentul in care dupa o grupare de forma "},\n", "}\n", "numar,\n" sau "numar\n" urmeaza un simbol "}"(s-au inchis toate parantezele
adica).

Se parcurge fiecare linie a inregistrarii curente la care ne aflam si se da "match" pe fiecare regula specifica fiecarui camp al acesteia. Am
considerat ca pentru un camp gasit avem o regula de forma "camp = ", pentru a printa astfel un mesaj corespunzator si a pune pe stiva starea
"EXTRACT_INFO" responsabila pentru extragerea "valorii" fiecarui camp in parte. Doar regula pentru "title" va pune pe stiva starea "EXTRACT_INFO_TITLE"
care este specifica doar titlului. In cazul in care gasim un alt camp decat cele prezentate in enuntul temei, atunci pun pe stiva starea
"IGNORE_OTHER_FIELDS" cu o regula care da "match" pe orice sir de forma:
    -> "numar,\n+" sau "numar\n+"(pentru formatul numerelor);
    -> "caractere diferite de '}'\n+" sau "caractere diferite de '}',\n+"(pentru orice format).
Doar campurile "pages" si "author" sunt tratate separat(la "author" pentru extragerea numelui fiecarui autor in parte si la "pages" pentru ignorarea
tutror zerourilor de la inceputul fiecarui numar si transformarea lui "--" in "-"). Aceste campuri au explicatii in comentariile din cod. 
Astfel sunt ignorate atat campurile cu tot cu liniile pe care acestea se afla.

In starea de "EXTRACT_INFO" se folosesc reguli de forma "{valoare}," sau "numar," in care se ignora ultimele 2, respectiv ultimul caracter din "yytext"
si se printeaza "yytext + 1", pentru a putea afisa valoarea din interior, dupa care starea curenta este scoasa de pe stiva si se continua analiza
inregistrarii in care ne aflam, sau ne aflam la finalul inregistrarii, aspect marcat de regula ce contorizeaza si simbolul "}", caz in care se procedeaza
in mod similar cazurilor anterioare, cu precizarea ca se de "yy_pop_state()" de 2 ori pentru a iesii atat din "EXTRACT_INFO", cat si din inregistrarea 
curenta marcata de una din cele 3 stari posibile. "EXTRACT_INFO_TITLE" este analog acestei stari, doar ca se printeaza titlul in format "\"%s\"".