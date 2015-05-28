import java.util.BitSet;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class ForwardCheckingSuccessor implements SuccessorFunction {

    //B+FC: backtracking search with forward checking (random variable order and random value order)
    // Forward checking is done by Alldiff on the remaining cells: one for each row, column, and region (box of 9)

    private Cell.CellComparatorRandom cellComparatorRandom = new Cell.CellComparatorRandom();

    @Override
    public Iterable<Grid> successors(Grid predecessor) {

        // essentially this filters the cells in the grid before generating unfilled cells
        final Grid partiallySolved = new Grid(predecessor);
        partiallySolved.allDiff();

        if (partiallySolved.isSolved()) {
            return Collections.singleton(partiallySolved);
        }

        if (!partiallySolved.isPossibleToSolve()) {
            return Collections.emptyList();
        }

        List<Cell> unfilledCells = partiallySolved.getUnfilledCells();
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
                        Grid newGrid = new Grid(partiallySolved);
                        newGrid.setCell(randomUnfilledCell.toIndex(), i);
                        i = possibleValues.nextSetBit(i + 1);
                        return newGrid;
                    }
                };
            }
        };
    }
}
