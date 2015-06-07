import java.util.*;

public class HeuristicsSuccessor implements SuccessorFunction {
    //B+FC+H: backtracking search with forward checking and the 3 heuristics to order variables and values
    // (break any remaining ties in the order of the variables and values at random)
    // Heuristics:
    //
    //      1/  minimum-remaining-values (MRV) AKA “most constrained variable” AKA “fail-first” heuristic
    // choosing the variable with the fewest “legal” values.
    // Picks a variable that is most likely to cause a failure soon, thereby pruning the search tree.
    // If some variable X has no legal values left, the MRV heuristic will select X and failure will be detected
    // immediately—avoiding pointless searches through other variables.
    //
    //      2/  degree heuristic
    // Attempts to reduce the branching factor on future choices by selecting the variable that is involved in
    // the largest number of constraints on other unassigned variables. Useful as a tie-breaker for 1/.
    //
    //      3/  least-constraining-value heuristic
    // Once a variable has been selected, the algorithm must decide on the order in which to examine its values.
    // We prefer the value that rules out the fewest choices for the neighboring variables in the constraint graph.

    private static final Comparator<Cell> cellComparator = new Cell.CellComparatorValueSize();
    private static final Comparator<Grid> gridComparator = new Grid.GridComparator();

    @Override
    public Iterable<Grid> successors(Grid predecessor) {

        final Grid grid = new Grid(predecessor);
        grid.allDiff();
        if (grid.isSolved()) {
            return Collections.singleton(grid);
        }

        if (!grid.isPossibleToSolve()) {
            return Collections.emptyList();
        }

        List<Cell> unfilledCells = grid.getUnfilledCells();
        // 1/   pick the most constrained variable "minCell"
        // 3/   pick the cell that has the least neighbours (to avoid constraining them)
        Cell minCell = Collections.min(unfilledCells, cellComparator);
        final BitSet possibleValues = minCell.getPossibleValues();

        LinkedList<Grid> grids = new LinkedList<Grid>();
        for (int i = possibleValues.nextSetBit(0); i >= 0; i = possibleValues.nextSetBit(i + 1)) {
            Grid newGrid = new Grid(grid);
            newGrid.setCell(minCell.toIndex(), i);
            grids.add(newGrid);
        }

        // 2/   Tie-break, try to prioritize by selecting the grid that has the most constrained variable (cell)
        // and consequently creating the largest number of constraints on other unassigned variables (cells).
        Collections.sort(grids, gridComparator);

        return grids;
    }

}

