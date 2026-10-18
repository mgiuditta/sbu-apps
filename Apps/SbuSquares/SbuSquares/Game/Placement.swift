/// What putting a piece down does: the cells it covers and the lines it completes.
nonisolated struct Placement: Hashable, Sendable {
    let covered: [Cell]
    let rows: [Int]
    let columns: [Int]

    /// How many rows and columns it completes.
    var lineCount: Int { rows.count + columns.count }

    /// The cells emptied by the completed lines.
    var cleared: Set<Cell> {
        let range = 0..<Board.size
        return Set(rows.flatMap { row in range.map { Cell(row: row, column: $0) } })
            .union(columns.flatMap { column in range.map { Cell(row: $0, column: column) } })
    }
}
