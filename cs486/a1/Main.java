import java.util.ArrayList;
import java.util.List;

public class Main {
    private final static int TRIALS = 50;

    public static void main(String[] args) {
//        basicTiming();
        basicFCTiming();
        heuristicsTiming();
    }

    private static void heuristicsTiming() {
        runTiming("Easy heuristics", Puzzles.easy_puzzle, TrialType.Heuristic);
        runTiming("Medium heuristics", Puzzles.medium_puzzle, TrialType.Heuristic);
        runTiming("Hard heuristics", Puzzles.hard_puzzle, TrialType.Heuristic);
        runTiming("Evil heuristics", Puzzles.evil_puzzle, TrialType.Heuristic);
    }

    private static void basicFCTiming() {
        runTiming("Easy FC", Puzzles.easy_puzzle, TrialType.FC);
        runTiming("Medium FC", Puzzles.medium_puzzle, TrialType.FC);
        runTiming("Hard FC", Puzzles.hard_puzzle, TrialType.FC);
        runTiming("Evil FC", Puzzles.evil_puzzle, TrialType.FC);
    }

    private static void basicTiming() {
        runTiming("Easy basic", Puzzles.easy_puzzle, TrialType.Basic);
        runTiming("Medium basic", Puzzles.medium_puzzle, TrialType.Basic);
        runTiming("Hard basic", Puzzles.hard_puzzle, TrialType.Basic);
        runTiming("Evil basic", Puzzles.evil_puzzle, TrialType.Basic);
    }

    private static void runTiming(String difficulty, String puzzle, TrialType trialType) {
        Grid grid = new Grid(puzzle);
        ArrayList<RunStat> runStats = new ArrayList<RunStat>();
        for (int i = 0; i < TRIALS; i++) {
            BacktrackSolver backtrackSolver = new BacktrackSolver(grid);
            RunStat stat;
            switch (trialType) {
                case Heuristic:
                    stat = backtrackSolver.solveBasicFCWithHeuristics();
                    break;
                case FC:
                    stat = backtrackSolver.solveBasicFC();
                    break;
                default:
                    stat = backtrackSolver.solveBasic();
                    break;
            }
            runStats.add(stat);
        }
        summarize(difficulty, runStats);
    }

    public static void summarize(String difficulty, List<RunStat> runStats) {
        int trials = runStats.size();
        double[] timing_data = new double[trials];
        double[] explored_data = new double[trials];
        for (int i = 0; i < trials; i++) {
            RunStat rs = runStats.get(i);
            timing_data[i] = rs.duration;
            explored_data[i] = rs.explored;
        }
        Statistics timingStats = new Statistics(timing_data);
        Statistics exploredStats = new Statistics(explored_data);
        System.out.println(difficulty + " summary");
        System.out.printf("%f avTime ± %f stdTime\n", timingStats.getMean(), timingStats.getStdDev());
        System.out.printf("%f avNodes ± %f stdNodes\n", exploredStats.getMean(), exploredStats.getStdDev());
    }

    private enum TrialType {Heuristic, FC, Basic,}


}
