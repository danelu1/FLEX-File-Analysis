class    Person {
    private String name;
    private int age;

    // constructor
    public Person(String name, int age) { this.name = name;
        this.age = age;
    }

    public void displayInfo() {
        System.out.println("Name: " + name + ", Age: " + age);
        Person p = new Person("", 0);
    }
}

class  Bogdan {
    Student s = new Student();
}

public class Student {
    private String nume;
    private int varsta;

    public Student() {
        this.nume = "None";
        this.varsta = 0;
    }

    public static void main(String[] args) {
        Student[] studenti = new Student[10];
        Student[] grigore = new Student[13];

        // for (int i = 0; i < grigore.length; i++) {
        //     grigore[i] = new Student();
        // }
        Student s1 = new Student();
        Student[] andrei = new Student[3];
        Person[] persons = new Person[200];
        Bogdan b = new Bogdan();
        Bogdan b1 = new Bogdan();

        for (int i = 0; i < persons.length; i++) {
            persons[i] = new Person("", i);
        }

        for (int i = 0; i < studenti.length; i++) {
            studenti[i] = new Student();
        }

        for (Student student : studenti) {
            System.out.println("Nume: " + student.nume + ", Varsta: " + student.varsta);
        }
    }
}
