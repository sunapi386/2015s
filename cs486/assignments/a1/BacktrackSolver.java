// A Grid is considered a state itself. We can store grid in a queue.

public class BacktrackSolver {
    private final Grid startingGrid;
    private Grid solvedGrid;
    private int explored = 0;

    public BacktrackSolver(Grid grid) {
        this.startingGrid = new Grid(grid);
    }

    public Grid solveRecursive(Grid grid, SuccessorFunction fn) {
        explored++;
        if (explored % 100000 == 0) {
//            System.out.println("\texplored " + explored + " \t: " + grid.toNumbers());
            System.out.print('.');
        }
        if (grid.isSolved()) {
            return grid;
        }
        if (!grid.isPossibleToSolve()) {
            return null;
        }

        for (Grid nextGrid : fn.successors(grid)) {
            Grid solved = solveRecursive(nextGrid, fn);
            if (solved != null) {
                return solved;
            }
        }

        return null;
    }

    public RunStat solveBasic() {
        long startTime = System.nanoTime();
        solvedGrid = solveRecursive(startingGrid, new RandomSuccessor());
        long endTime = System.nanoTime();
        long duration = (endTime - startTime) / 1000000;
        System.out.printf("Basic:      %d ms, %d explored.\n", duration, explored);
        return new RunStat(duration, explored, solvedGrid);
    }

    public RunStat solveBasicFC() {
        long startTime = System.nanoTime();
        solvedGrid = solveRecursive(startingGrid, new ForwardCheckingSuccessor());
        long endTime = System.nanoTime();
        long duration = (endTime - startTime) / 1000000;
//        System.out.printf("Fwd-Chk:    %d ms, %d explored.\n", duration, explored);
        return new RunStat(duration, explored, solvedGrid);
    }

    public RunStat solveBasicFCWithHeuristics() {
        long startTime = System.nanoTime();
        solvedGrid = solveRecursive(startingGrid, new HeuristicsSuccessor());
        long endTime = System.nanoTime();
        long duration = (endTime - startTime) / 1000000;
//        System.out.printf("Heuristics: %d ms, %d explored.\n", duration, explored);
        return new RunStat(duration, explored, solvedGrid);


    }


}
