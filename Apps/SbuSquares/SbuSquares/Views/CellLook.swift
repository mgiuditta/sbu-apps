/// How one board cell is drawn.
enum CellLook: Hashable {
    case empty
    case filled
    /// Empty, where the dragged piece would land.
    case shadow
    /// Filled or about to be, in a line the dragged piece would complete.
    case completing
}
