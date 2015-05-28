import java.util.*;

/**
 * A Sudoku 9x9 grid.
 * 9 regions:
 * A B C
 * D E F
 * G H I
 */
public class Grid {
    Cell[] grid = new Cell[81];

    public Grid(String s) {
        assert (s.length() == 81);
        int s_index = 0;
        for (int x = 0; x < 9; x++) {
            for (int y = 0; y < 9; y++) {
                grid[s_index] = new Cell(x, y, s.charAt(s_index));
                s_index++;
            }
        }
    }

    public Grid(Grid g) { // deep copy
        for (Cell c : g.grid) {
            grid[c.toIndex()] = new Cell(c);
        }
    }

    private static int toIndex(int x, int y) {
        // key into the hashmap
        return x * 9 + y;
    }

    public Cell getCell(int x, int y) {
        return grid[toIndex(x, y)];
    }

    private void cellsAllDiff(Collection<Cell> cells) throws Exception {
        // all diffs on the list of cells, make sure they're all different values
        BitSet validValues = new BitSet(10);
        for (Cell c : cells) { // first do a scan for all valid entries
            if (c.isValid()) {
                int value = c.getValue();
                if (validValues.get(value)) {
                    // error, it should not contain duplicate values!
//                    System.out.println("Error: duplicate value " + c.toString() + " at " + c.coords());
                    throw new Exception();
                }
                validValues.set(value);
            }
        }
        // then for each invalid cell, filter out possible values
        for (Cell c : cells) {
            c.filterOut(validValues);
        }
    }

    private Collection<Collection<Cell>> generateAllZones() {
        Collection<Collection<Cell>> zones = new LinkedList<Collection<Cell>>();
        for (int i = 0; i < 9; i++) {
            zones.add(getRow(i));
        }
        for (int i = 0; i < 9; i++) {
            zones.add(getCol(i));
        }
        for (Region r : Region.values()) {
            zones.add(getRegion(r));
        }
        return zones;
    }


    public Collection<Cell> getRow(int row) {
        Collection<Cell> result = new LinkedList<Cell>();
        for (int col = 0; col < 9; col++) {
            result.add(grid[toIndex(row, col)]);
        }
        return result;
    }

    public Collection<Cell> getCol(int col) {
        Collection<Cell> result = new LinkedList<Cell>();
        for (int row = 0; row < 9; row++) {
            result.add(grid[toIndex(row, col)]);
        }
        return result;
    }

    public Collection<Cell> getRegion(Region rgn) {
        int row_l = -1, row_h = -1;
        if (rgn.equals(Region.A) || rgn.equals(Region.B) || rgn.equals(Region.C)) {
            row_l = 0;
            row_h = 2;
        }
        if (rgn.equals(Region.D) || rgn.equals(Region.E) || rgn.equals(Region.F)) {
            row_l = 3;
            row_h = 5;
        }
        if (rgn.equals(Region.G) || rgn.equals(Region.H) || rgn.equals(Region.I)) {
            row_l = 6;
            row_h = 8;
        }

        int col_l = -1, col_h = -1;
        if (rgn.equals(Region.A) || rgn.equals(Region.D) || rgn.equals(Region.G)) {
            col_l = 0;
            col_h = 2;
        }
        if (rgn.equals(Region.B) || rgn.equals(Region.E) || rgn.equals(Region.H)) {
            col_l = 3;
            col_h = 5;
        }
        if (rgn.equals(Region.C) || rgn.equals(Region.F) || rgn.equals(Region.I)) {
            col_l = 6;
            col_h = 8;
        }

        Collection<Cell> result = new LinkedList<Cell>();
        for (int row = row_l; row <= row_h; row++) {
            for (int col = col_l; col <= col_h; col++) {
                result.add(grid[toIndex(row, col)]);
            }
        }
        return result;
    }

    public List<Cell> getUnfilledCells() {
        List<Cell> unfilledCells = new ArrayList<Cell>();
        for (Cell c : grid) {
            if (!c.isValid()) {
                unfilledCells.add(c);
            }
        }
        return unfilledCells;
    }

    public int countInvalids() {
        int count = 0;
        for (Cell c : grid) {
            if (!c.isValid()) {
                count += 1;
            }
        }
        return count;
    }

    public void allDiff() {
        // allDiff on row, column, and region
        long startTime = System.nanoTime();
        for (; ; ) {
            int invalids_before = countInvalids();
            for (Collection<Cell> zone : generateAllZones()) {
                try {
                    cellsAllDiff(zone);
                } catch (Exception e) {
                    return;
                }
            }
            int invalids_after = countInvalids();
//            System.out.println("" + (invalids_before - invalids_after));
            if (invalids_before == invalids_after) {
                break;
            }
        }
        long endTime = System.nanoTime();
        long duration = (endTime - startTime);
        String unsolved = isSolved() ? "" : " unsolved cells: " + countInvalids();
//        System.out.println("Time allDiff: " + duration + unsolved);
    }

    public void print() {
        for (int row = 0; row < 9; row++) {
            for (int col = 0; col < 9; col++) {
                System.out.printf("%-28s", getCell(row, col).toString());
                if ((col + 1) % 3 == 0 && col < 8) {
                    System.out.print(" || ");
                }
            }
            System.out.println();
            if ((row + 1) % 3 == 0 && row < 8) {
                System.out.println(new String(new char[265]).replace('\0', '='));
            }
        }
        System.out.println();
    }

    public boolean verifyWithPuzzleSolution(String s) {
        boolean ret = false;
        StringBuilder sb = new StringBuilder(81);
        if (countInvalids() == 0) {
            for (Cell c : grid) {
                sb.append(c.getValue());
            }
            ret = sb.toString().equals(s);
        }
        System.out.println("compare: " + ret);
        if (!ret) {
            System.out.println("Grid  " + sb.toString());
            System.out.println("Given " + s);
        }
        return ret;
    }

    public boolean isSolved() {
        if (countInvalids() != 0) {
            // firstly the board should have all cells have exactly one value
            return false;
        }
        // secondly those values should be consistent for all 3 zones: row, column, region
        for (Collection<Cell> cellCollection : generateAllZones()) {
//            System.out.println("zone " + cellCollection.toString());
            Set<Integer> seenNumbers = new HashSet<Integer>();
            // in each zone we should only have seen numbers 1 to 9 exactly once
            for (Cell c : cellCollection) {
                if (seenNumbers.contains(c.getValue())) {
                    return false; // we should not have already seen this value
                }
                seenNumbers.add(c.getValue());
            }
            // check the values we added are exactly 1 to 9
            for (int i = 1; i <= 9; i++) {
                if (!seenNumbers.contains(i)) {
                    // if it doesn't contain 1 to 9 then there's error
                    return false;
                }
            }
        }
        // grid is solved when numbers in cells are consistent and there are no invalid cells
        return true;
    }

    public boolean isPossibleToSolve() {
        if (countInvalids() == 0) {
            // there should be unsolved cells to be possible to solve
            return false;
        }
        // similar to isSolved() except we don't check that values from 1 to 9 all exists in each zone
        for (Collection<Cell> cellCollection : generateAllZones()) {
//            System.out.println("zone " + cellCollection.toString());
            Set<Integer> seenNumbers = new HashSet<Integer>();
            for (Cell c : cellCollection) {
                if (c.isValid()) { // only check consistency if the cell has values filled in
                    if (seenNumbers.contains(c.getValue())) {
                        return false;
                    }
                    seenNumbers.add(c.getValue());
                } else if (c.getPossibleValues().size() == 0) {
                    return false;
                }
            }
        }
        return true;
    }

    public void setCell(int x, int y, int n) {
        grid[toIndex(x, y)].setNumber(n);
    }

    public void setCell(int index, int n) {
        grid[index].setNumber(n);
    }

    public void setCellPossibleValues(int x, int y, BitSet values) {
        grid[toIndex(x, y)].setPossibleValues(values);
    }

    public String toNumbers() {
        StringBuilder sb = new StringBuilder(81);

        for (Cell c : grid) {
            String val = c.isValid() ? String.valueOf(c.getValue()) : "-";
            sb.append(val);
        }

        return sb.toString();
    }

    public Collection<Cell> countUnfilledNeighbors(Cell cell) {
        Collection<Cell> neighbors = getCol(cell.getCol());
        neighbors.addAll(getRegion(cell.getRegion()));
        neighbors.addAll(getRow(cell.getRow()));
        LinkedList<Cell> unfilledCells = new LinkedList<Cell>();
        for (Cell neighborCell : neighbors) {
            if (!neighborCell.isValid()) {
                unfilledCells.add(neighborCell);
            }
        }
        return unfilledCells;
    }

    public enum Region {
        A, B, C,
        D, E, F,
        G, H, I,
    }

    public static class GridComparator implements Comparator<Grid> {
        private Cell.CellComparatorValueSize cellComparatorValueSize = new Cell.CellComparatorValueSize();

        @Override
        public int compare(Grid o1, Grid o2) {
            if (o1.countInvalids() < o2.countInvalids()) {
                return -1;
            }
            if (o1.countInvalids() > o2.countInvalids()) {
                return 1;
            }
            Cell cell1 = Collections.min(o1.getUnfilledCells(), cellComparatorValueSize);
            Cell cell2 = Collections.min(o2.getUnfilledCells(), cellComparatorValueSize);
            return cellComparatorValueSize.compare(cell1, cell2);
        }
    }

}
