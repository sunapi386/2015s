import java.util.BitSet;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class RandomSuccessor implements SuccessorFunction {
    private Cell.CellComparatorRandom cellComparatorRandom = new Cell.CellComparatorRandom();

    @Override
    public Iterable<Grid> successors(final Grid predecessor) {
        List<Cell> unfilledCells = predecessor.getUnfilledCells();
        // the grid should be possible to solve, no internal conflicting numbers exist
        // choose a random unfilled cell and create new states (grid) for each possible value

        // the sort is actually consistent random shuffle, for the sole purpose of keeping track of what cells
        // we have already guessed, so to prune the search space and not repeatedly guess the same cells
        // it is consistent because the cell comparator is created once and the value is final
        // and it is random because the the value is randomized on creation
        final Cell randomUnfilledCell = Collections.min(unfilledCells, cellComparatorRandom);
        final BitSet possibleValues = randomUnfilledCell.getPossibleValues();

        return new Iterable<Grid>() {
            @Override
            public Iterator<Grid> iterator() {
                return new Iterator<Grid>() {
                    int i = possibleValues.nextSetBit(0);

                    @Override
                    public boolean hasNext() {
                        return i != -1;
                    }

                    @Override
                    public Grid next() {
                        Grid newGrid = new Grid(predecessor);
                        newGrid.setCell(randomUnfilledCell.toIndex(), i);
                        i = possibleValues.nextSetBit(i + 1);
                        return newGrid;
                    }
                };
            }
        };
    }
}
