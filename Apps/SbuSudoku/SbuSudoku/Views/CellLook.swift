/// How the selection reaches one cell.
enum CellLook: Hashable {
    case plain
    case selected
    /// In the selected cell's row, column or box.
    case area
    /// Holds the selected cell's digit.
    case sameDigit
}
