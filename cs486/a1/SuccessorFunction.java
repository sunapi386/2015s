public interface SuccessorFunction {
    Iterable<Grid> successors(Grid predecessor);
}