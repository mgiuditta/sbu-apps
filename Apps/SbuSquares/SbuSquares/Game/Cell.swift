/// A square of the board, counted from the top left.
nonisolated struct Cell: Codable, Hashable, Sendable {
    var row: Int
    var column: Int

    /// The cell `offset` away from this one.
    func moved(by offset: Cell) -> Cell {
        Cell(row: row + offset.row, column: column + offset.column)
    }
}
