class Serghei {
    public static void main(String[] args) {
        int a = 3;

        Animal[] animals = new Animal[100];
        Serghei s = new Serghei();
        Manatarca[] piata = new Manatarca[13];
        Google[] google = new Google[31];
        
        for (int i = 0; i < animals.length; i++) {
            animals[i] = new Animal();
        }

        Manatarca m = new Manatarca();

        for (int i = 0; i < google.length; i++) {
            google[i] = new Google();
        }

        Animal b = new Animal();
    }
}

public class Animal {
    private float weight;
    private boolean small;
    private String name;

    public void setWeight(float w) {
        this.weight = w;
    }

    public String getName() {
        return name;
    }

    public void setSmall(boolean s) {
        this.small = s;
    }

    public void setName(String dsjlvndsjlvna) {
        this.name = dsjlvndsjlvna;
    }

    public boolean getSmall() {
        return small;
    }

    public void method() {
        System.out.println("La multi ani!!!");
    }
}

class Manatarca {
    private int field;
    private String f;
    Animal s = new Animal();

    public int getField() {
        return field;
    }

    public void setField(int a) {
        this.field = a;
    }

    public String getF() {
        return f;
    }

    public Manatarca() {
        field = 2;
        f = "abcdef";
    }
}

class Google {
    public void run() {
        System.out.println("Alerg.");
    }

    private boolean check;

    public void setCheck(boolean b) {
        this.check = b;
    }

    public boolean getCheck() {
        return check;
    }
}