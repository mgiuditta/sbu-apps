/// What a cell shows. A value is an error only when it differs from the solution, not when it
/// repeats a digit, and only while mistakes are checked: unchecked, every value is `ok`.
nonisolated enum CellState: Sendable {
    case empty
    case error
    case ok
    /// Given, or placed by a hint: it can no longer change.
    case constant
}
