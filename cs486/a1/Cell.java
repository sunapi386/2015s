import java.util.BitSet;
import java.util.Comparator;
import java.util.Random;

/**
 */
public class Cell {
    private BitSet possibleValues = new BitSet();
    private int x, y; // record cell location, possibly useful for debugging

    public Cell(int x, int y, char c) {
        String s = String.valueOf(c);
        Integer value;
        if(isNumeric(s) && (value = Integer.valueOf(s)) > 0) {
            possibleValues.set(value);
        } else {
            for (int i = 1; i <= 9; i++) {
                possibleValues.set(i);
            }
        }
        this.x = x;
        this.y = y;
    }

    public Cell(Cell c) {
        possibleValues = new BitSet();
        possibleValues.or(c.possibleValues);
        x = c.x;
        y = c.y;
    }

    private static boolean isNumeric(String str)  {
        try {
            Double.parseDouble(str);
        }
        catch(NumberFormatException nfe)         {
            return false;
        }
        return true;
    }

    public void setNumber(int n) {
        possibleValues = new BitSet();
        possibleValues.set(n);
    }

    boolean isValid() {
        int nextNumber = possibleValues.nextSetBit(0);
        return (nextNumber != -1) && (possibleValues.nextSetBit(nextNumber + 1) == -1);
    }

    public BitSet getPossibleValues() {
        return possibleValues;
    }

    public void setPossibleValues(BitSet values) {
        possibleValues = new BitSet();
        possibleValues.or(values);
    }

    public Integer getValue() {
        return possibleValues.nextSetBit(0);
    }

    public void filterOut(BitSet validValues) {
        if (!isValid()) {
            possibleValues.andNot(validValues);
        }
    }

    @Override
    public String toString() {
        return possibleValues.toString();
    }

    public int toIndex() {
        // key into the hashmap
        return x * 9 + y;
    }

    public int getX() {
        return x;
    }

    public int getY() {
        return y;
    }

    public int getCol() {
        return y + 1;
    }

    //              0,1,2,      3,4,5,          6,7,8
//            9,10,11,    12,13,14        15,16,17,
//            18,19,20,   21,22,23,       24,25,26,
//
//
//            27,28,29    ,30,31,32       ,33,34,35
//            ,36,37,38   ,39,40,41       ,42,43,44
//            ,45,46,47   ,48,49,50       ,51,52,53
//
//
//            ,54,55,56   ,57,58,59       ,60,61,62
//            ,63,64,65   ,66,67,68       ,69,70,71
//            ,72,73,74   ,75,76,77       ,78,79,80
    public Grid.Region getRegion() {
        switch (toIndex()) {
            case 0:
            case 1:
            case 2:
                return Grid.Region.A;
            case 3:
            case 4:
            case 5:
                return Grid.Region.B;
            case 6:
            case 7:
            case 8:
                return Grid.Region.C;
            case 9:
            case 10:
            case 11:
                return Grid.Region.A;
            case 12:
            case 13:
            case 14:
                return Grid.Region.B;
            case 15:
            case 16:
            case 17:
                return Grid.Region.C;
            case 18:
            case 19:
            case 20:
                return Grid.Region.A;
            case 21:
            case 22:
            case 23:
                return Grid.Region.B;
            case 24:
            case 25:
            case 26:
                return Grid.Region.C;
            case 27:
            case 28:
            case 29:
                return Grid.Region.D;
            case 30:
            case 31:
            case 32:
                return Grid.Region.E;
            case 33:
            case 34:
            case 35:
                return Grid.Region.F;
            case 36:
            case 37:
            case 38:
                return Grid.Region.D;
            case 39:
            case 40:
            case 41:
                return Grid.Region.E;
            case 42:
            case 43:
            case 44:
                return Grid.Region.F;
            case 45:
            case 46:
            case 47:
                return Grid.Region.D;
            case 48:
            case 49:
            case 50:
                return Grid.Region.E;
            case 51:
            case 52:
            case 53:
                return Grid.Region.F;
            case 54:
            case 55:
            case 56:
                return Grid.Region.G;
            case 57:
            case 58:
            case 59:
                return Grid.Region.H;
            case 60:
            case 61:
            case 62:
                return Grid.Region.I;
            case 63:
            case 64:
            case 65:
                return Grid.Region.G;
            case 66:
            case 67:
            case 68:
                return Grid.Region.H;
            case 69:
            case 70:
            case 71:
                return Grid.Region.I;
            case 72:
            case 73:
            case 74:
                return Grid.Region.G;
            case 75:
            case 76:
            case 77:
                return Grid.Region.H;
            case 78:
            case 79:
            case 80:
                return Grid.Region.I;
        }
        return Grid.Region.A;
    }

    public int getRow() {
        return x + 1;
    }

    public static class CellComparatorRandom implements Comparator<Cell> {
        private static Random random = new Random();

        private final int xMult = random.nextInt(1000);
        private final int yMult = random.nextInt(1000);
        private final int truncation = 200;

        @Override
        public int compare(Cell o1, Cell o2) {
            int order1 = (o1.x * xMult + o1.y * yMult) % truncation;
            int order2 = (o2.x * xMult + o2.y * yMult) % truncation;
            return order1 - order2;
        }
    }

    public static class CellComparatorValueSize implements Comparator<Cell> {
        @Override
        public int compare(Cell o1, Cell o2) {
            return o1.getPossibleValues().size() - o2.getPossibleValues().size();
        }
    }

}