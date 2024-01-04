Osnaga Robert-Viorel - 332CC

Am ales sa fac tema integral in "C", folosind "Visual Studio Code".

In rezolvarea temei m-am lovit de foarte multe situatii legate in mare parte de utilizarea "FLEX"-ului in favoarea "C"-ului si de modul
de extragere al anumitor string-uri din interiorul unei reguli, incercand sa modific implementarea initiala ce folosea "sscanf"(pentru
a extrage anumite subsiruri tot in functie de niste reguli) cu una ce utilizeaza stiva de stari din "FLEX".

Initial am considerat o regula ce recunoaste clasele din fisierul de test. Am tinut astfel cont de 2 situatii posibile ce pot aparea:
clase publice si clase "implicite". Astfel am creat regulile de forma "class Nume" si "public class Nume", extragand astfel numele clasei
respective si adaugand-o atat in vectorul cu numele claselor, cat si in dictionarul responsabil cu instantierile pentru clase. In cazul in
care gasesc 2 clase publice, in fisierul de output afisez un mesaj de eroare. Pe langa dictionarul cu instantieri, mai am si 2 dictionare
pe care le folosesc pentru determinarea numarului de metode "get" si "set" implementate pentru campurile private a clasei curente in care
ne aflam. Am aduagat pe stiva starea responsabila cu analiza campurilor din clasa.

Starea "FIELDS" este starea principala aflata pe varful stivei pana in momentul in care clasa curenta procesata este terminata. Am considerat
ca pentru a contoriza cand se termina o clasa, retin intr-o variabila numarul de acolade deschise intalnite in aceasta(cu ajutorul regulii
"<FIELDS>\{", in care incrementez acest numar), dupa care la fiecare paranteza inchisa, decrementez acest numar. La final, cand numarul de
paranteze ajunge la 0, salvez situatia pentru metodele de "get" si "set" implementate intr-un sir de caractere, pe care ulterior il printez
in "main" in fisierul de output. Faptul ca avem 0 paranteze garanteza faptul ca am terminat de analizat clasa curenta si astel putem incrementa
numarul de clase gasite(la fel tratez si metoda "main" din fisierele de test).
In interiorul starii "FIELDS" am o regula de forma "private Nume(""|[])" pentru a gasii declararea unui camp privat. De aici scot tipul de date
al campului, dupa care adaug in stiva urmatoarea stare prin care extrag si numele campului. Scot starea de extragere a campului de pe stiva, dupa
care urmeaza regulile responsabile din starea "FIELDS" a tratarii metodelor de "get" si "set". In cazul gasirii unei metode de "set" am folosit o
regula de forma "public void setNumeCamp", de unde am extras numele campului si am verificat prin intermediul unui dictionar(pe care il actualizez
in momentul extragerii numelui campului) ce contine cheile de forma "NumeClasa numeCamp", daca numele campului extras dupa "set"(a carui litera am
facut-o mica) exista in dictionar. Astfel ne-am asigurat de faptul ca pentru campul respectiv s-a implementat metoda de "set" si putem incrementa
numarul unor astfel de metode. Analog am procedat si in cazul metodei "get", doar ca in plus am verificat daca tipul returnat de metoda este acelasi
cu cel al campului corespunzator, folosind un dicitionar ce retine pe langa numele clasei si al campului si tipul de date al acestuia.

Pentru tratarea metodei "main" am identificat string-ul pus la dispozitie si in enuntul temei, dupa care am procedat analog tratarii unei clase,
tinand cont de acolade pentru a stii cand iesim din metoda "main"(deoarece doar de acolo avem voie sa numaram instantele).
Am considerat in interiorul starii "MAIN" mai multe reguli responsabile cu "gasirea" alocarii unui array si a instantierii acestuia sau a unui
obiect. Am creat regulile care determina declararea si alocarea unui array, de unde am reusit sa extrag progresiv, prin intermediul a 3 stari,
tipul de date al array-ului, numele acestuia, tipul de date de dupa egal(adica cel de la "new Tip[...]"), pentru a verifica sa fie acelasi ca in
partea stanga, altfel n-ar avea sens sa continuam(caz pe care l-am tratat prin eliminarea de pe stiva a starilor cumulate si intoarcerea inapoi
la starea "MAIN" pentru a cauta alte reguli) si, intr-un final, numarul de obiecte alocate. Am continuat dupa cu o alta regula a starii "MAIN" care
determina siruri de caractere de forma "Tip[caracter" pentru a stii ca se face astfel instantierea pentru obiectele din array in interiorul unui "for".
In urma gasirii unui "match" pe aceasta regula, am verificat in continuare daca exista acel array in dictionarul responsabil pentru alocari, caz in
care treceam la starea responsabila cu actualizarea dictionarului cu instantele pentru clase, unde cautam clasa cu care s-a declarat array-ul repsectiv
si ii actualizam valoarea. Pentru instantele simple am folosit o regula de forma "Tip nume = new Tip(", unde am extras tipul si de pe stanga si de pe
dreapta si am verificat sa fie acelasi si sa se afle si clasa in dictionar, caz in care incrementez numarul de instante pentru aceasta, iar in cazul in
care aceasta nu era in dictionar, adaugam "default" valoarea 1. Clasele "wrapper" ale limbajului le-am ignorat(atat instantele simple, cat si array-urile).
In functiile "contains" si "getValue" din implementarea dictionarului, extrag prima aparitie a cuvantului respectiv, daca acesta exista in dictionar si daca
dupa parcurgerea lungimii lui intalnim fie un ' ' sau un '\0'(am facut asta pentru cazuri cum sunt "Bike" si "BikeFactory" pentru a nu incrementa numarul de
instante pentru "Bike" in momentul instantierii unui obiect "BikeFactory").