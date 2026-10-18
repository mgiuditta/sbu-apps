/// One game: the board, the three pieces on offer, the score.
///
/// Pieces come only from the seeded generator, three at a time, each shape equally likely.
/// Nothing tunes them to the board or to the player (ADR-0015).
nonisolated struct Game: Codable, Hashable, Sendable {
    let mode: GameMode
    let seed: UInt64
    /// The Record when the game started: beating it turns the full stop `.set`.
    let recordToBeat: Int

    private(set) var board = Board()
    /// The catalog index of each piece on offer, `nil` once used.
    private(set) var tray: [Int?] = []
    private(set) var score = 0
    private(set) var lines = 0
    private(set) var isOver = false
    private var generator: SeededGenerator

    init(mode: GameMode, seed: UInt64, recordToBeat: Int) {
        self.mode = mode
        self.seed = seed
        self.recordToBeat = recordToBeat
        generator = SeededGenerator(seed: seed)
        refill()
    }

    /// The piece in `slot`, or `nil` once used.
    func piece(in slot: Int) -> Piece? {
        tray[slot].map { Piece.catalog[$0] }
    }

    /// Whether this game has gone past the Record it started with. The first game sets the
    /// Record without beating one: the full stop waits.
    var beatsRecord: Bool {
        recordToBeat > 0 && score > recordToBeat
    }

    /// Puts the piece in `slot` down at `origin`; `nil`, and nothing changes, if it does not fit.
    @discardableResult
    mutating func place(slot: Int, at origin: Cell) -> Placement? {
        guard !isOver, let dropped = piece(in: slot), let placement = board.preview(dropped, at: origin) else { return nil }
        board.apply(placement)
        score += placement.points
        lines += placement.lineCount
        tray[slot] = nil
        if tray.allSatisfy({ $0 == nil }) { refill() }
        isOver = !tray.indices.contains { piece(in: $0).map(board.hasRoom(for:)) ?? false }
        return placement
    }

    private mutating func refill() {
        // Not Int.random(in:using:): its algorithm may change between Swift versions, and the
        // Partita del giorno must stay the same on every build. The modulo bias is below 1e-17.
        tray = (0..<3).map { _ in Int(generator.next() % UInt64(Piece.catalog.count)) }
    }
}
