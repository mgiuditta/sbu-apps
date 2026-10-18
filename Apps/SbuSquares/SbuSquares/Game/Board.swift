/// The 8 × 8 grid: which cells are filled, and with which piece's tone.
nonisolated struct Board: Codable, Hashable, Sendable {
    static let size = 8

    private var tones: [Int?]

    /// An empty board.
    init() {
        tones = Array(repeating: nil, count: Self.size * Self.size)
    }

    /// Whether `cell` is filled.
    subscript(cell: Cell) -> Bool {
        tone(at: cell) != nil
    }

    /// The tone of the piece that filled `cell`, `nil` if empty.
    func tone(at cell: Cell) -> Int? {
        tones[Self.index(of: cell)]
    }

    /// The number of filled cells.
    var filledCount: Int { tones.count { $0 != nil } }

    /// Whether `piece` fits with its top-left corner on `origin`: inside the board, on empty cells.
    func canPlace(_ piece: Piece, at origin: Cell) -> Bool {
        piece.cells.allSatisfy { offset in
            let cell = origin.moved(by: offset)
            return Self.contains(cell) && !self[cell]
        }
    }

    /// Whether `piece` fits anywhere.
    func hasRoom(for piece: Piece) -> Bool {
        Self.allCells.contains { canPlace(piece, at: $0) }
    }

    /// The cells `piece` would cover at `origin`, and the lines it would complete; `nil` if it does not fit.
    func preview(_ piece: Piece, at origin: Cell) -> Placement? {
        guard canPlace(piece, at: origin) else { return nil }
        var board = self
        let covered = piece.cells.map { origin.moved(by: $0) }
        for cell in covered { board.tones[Self.index(of: cell)] = 0 }
        let rows = (0..<Self.size).filter { row in (0..<Self.size).allSatisfy { board[Cell(row: row, column: $0)] } }
        let columns = (0..<Self.size).filter { column in (0..<Self.size).allSatisfy { board[Cell(row: $0, column: column)] } }
        return Placement(covered: covered, rows: rows, columns: columns)
    }

    /// Fills the cells of `placement` in `tone`, then empties the lines it completed.
    mutating func apply(_ placement: Placement, tone: Int = 0) {
        for cell in placement.covered { tones[Self.index(of: cell)] = tone }
        for cell in placement.cleared { tones[Self.index(of: cell)] = nil }
    }

    /// Every cell, row by row.
    static let allCells: [Cell] = (0..<size).flatMap { row in (0..<size).map { Cell(row: row, column: $0) } }

    static func contains(_ cell: Cell) -> Bool {
        (0..<size).contains(cell.row) && (0..<size).contains(cell.column)
    }

    private static func index(of cell: Cell) -> Int {
        cell.row * size + cell.column
    }
}
