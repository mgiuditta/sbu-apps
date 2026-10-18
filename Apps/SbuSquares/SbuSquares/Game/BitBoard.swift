/// The board as 64 bits, one per cell (`row * 8 + column`), for the dealer's searches.
nonisolated struct BitBoard: Hashable, Sendable {
    private(set) var bits: UInt64

    init(_ board: Board) {
        bits = Board.allCells.reduce(0) { bits, cell in board[cell] ? bits | Self.bit(cell) : bits }
    }

    /// Every position of every catalog shape inside the board, as masks.
    static let placements: [[UInt64]] = Piece.catalog.map { piece in
        Board.allCells.compactMap { origin in
            let cells = piece.cells.map { origin.moved(by: $0) }
            guard cells.allSatisfy(Board.contains) else { return nil }
            return cells.reduce(0) { $0 | bit($1) }
        }
    }

    /// Whether `mask` lies on empty cells.
    func fits(_ mask: UInt64) -> Bool {
        bits & mask == 0
    }

    /// Whether the catalog shape `piece` fits anywhere.
    func fits(piece: Int) -> Bool {
        Self.placements[piece].contains(where: fits)
    }

    /// Fills `mask`, empties the rows and columns it completes, and returns how many.
    @discardableResult
    mutating func put(_ mask: UInt64) -> Int {
        bits |= mask
        let full = Self.lines.filter { bits & $0 == $0 }
        bits &= ~full.reduce(0, |)
        return full.count
    }

    /// Whether putting `mask` down completes a line.
    func completes(_ mask: UInt64) -> Bool {
        var board = self
        return board.put(mask) > 0
    }

    /// Whether the catalog shapes `pieces` can all go down, in some order and somewhere.
    // ponytail: exhaustive search, at most 3 × 64 × 2 × 64 × 64 puts when it fails; fine at 8 × 8.
    func survives(_ pieces: [Int]) -> Bool {
        guard !pieces.isEmpty else { return true }
        return Set(pieces).contains { piece in
            var rest = pieces
            rest.remove(at: rest.firstIndex(of: piece)!)
            return Self.placements[piece].contains { mask in
                guard fits(mask) else { return false }
                var board = self
                board.put(mask)
                return board.survives(rest)
            }
        }
    }

    /// Filled ↔ empty changes between neighbouring cells, along rows and columns: low is tidy.
    var edge: Int {
        ((bits ^ (bits >> 1)) & 0x7F7F_7F7F_7F7F_7F7F).nonzeroBitCount
            + ((bits ^ (bits >> 8)) & 0x00FF_FFFF_FFFF_FFFF).nonzeroBitCount
    }

    /// The empty cell of every row and column that has exactly one, as masks.
    var lastHoles: [UInt64] {
        Array(Set(Self.lines.filter { (bits & $0).nonzeroBitCount == Board.size - 1 }.map { $0 & ~bits })).sorted()
    }

    /// The eight rows, then the eight columns.
    private static let lines: [UInt64] = (0..<Board.size).map { UInt64(0xFF) << ($0 * Board.size) }
        + (0..<Board.size).map { UInt64(0x0101_0101_0101_0101) << $0 }

    private static func bit(_ cell: Cell) -> UInt64 {
        1 << (cell.row * Board.size + cell.column)
    }
}
