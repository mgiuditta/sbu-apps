/// One of the shapes the tray offers, as cells relative to its top-left corner.
nonisolated struct Piece: Hashable, Sendable {
    /// The cells of the shape; the smallest row and column are both 0.
    let cells: [Cell]

    /// Rows the shape spans.
    var height: Int { (cells.map(\.row).max() ?? 0) + 1 }

    /// Columns the shape spans.
    var width: Int { (cells.map(\.column).max() ?? 0) + 1 }

    /// Builds a shape from rows drawn with `#` for a filled cell.
    init(_ rows: String...) {
        cells = rows.enumerated().flatMap { row, line in
            line.enumerated().compactMap { column, mark in
                mark == "#" ? Cell(row: row, column: column) : nil
            }
        }
    }

    /// Every shape the generator draws from, each equally likely.
    static let catalog: [Piece] = [
        Piece("#"),
        Piece("##"), Piece("#", "#"),
        Piece("###"), Piece("#", "#", "#"),
        Piece("####"), Piece("#", "#", "#", "#"),
        Piece("#####"), Piece("#", "#", "#", "#", "#"),
        Piece("##", "##"),
        Piece("###", "###", "###"),
        Piece("#.", "##"), Piece(".#", "##"), Piece("##", "#."), Piece("##", ".#"),
        Piece("#.", "#.", "##"), Piece(".#", ".#", "##"), Piece("##", "#.", "#."), Piece("##", ".#", ".#"),
        Piece("###", ".#."), Piece(".#.", "###"),
        Piece("##.", ".##"), Piece(".##", "##."),
        Piece("###", "#..", "#.."), Piece("###", "..#", "..#"),
    ]
}
