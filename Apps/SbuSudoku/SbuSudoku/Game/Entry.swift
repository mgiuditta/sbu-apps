/// What happened to a digit, an erase or a hint on the selected cell.
nonisolated enum Entry: Equatable, Sendable {
    case placed
    case noted
    case erased
    /// Nothing to change: the cell is empty, or no cell is selected.
    case ignored
    /// The cell already holds the right digit and mistakes are checked: it stays as it is.
    case alreadyCorrect
    /// The cell was given, or placed by a hint.
    case given
}
