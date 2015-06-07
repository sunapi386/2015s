public class RunStat {
    // container for runtime summary
    public long duration;
    public int explored;
    public Grid solvedGrid;

    public RunStat(long duration, int explored, Grid solvedGrid) {
        this.duration = duration;
        this.explored = explored;
        this.solvedGrid = solvedGrid;
    }

}
    