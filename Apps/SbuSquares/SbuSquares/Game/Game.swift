import Foundation

/// One game: the board, the three pieces on offer, the score.
///
/// Pieces come from the `Dealer`, three at a time, with the original's strategies: half the trays
/// random but never dead and half raising the entropy, a puzzle after two or three minutes and then every 30 to 60 seconds, fill
/// and clear instead of the puzzle after a lost game (up to three), no small shapes past 2000
/// points, no lines when the trays loop.
nonisolated struct Game: Codable, Hashable, Sendable {
    /// Points for emptying the board, from the sixth tray on.
    static let clearBoardPoints = 300
    /// Trays after which emptying the board scores.
    static let clearBoardFromRound = 5
    /// Trays at the start that leave out the shapes left in hand when the last game ended.
    static let avoidRounds = 3
    /// Lost games that turn a puzzle into fill and clear.
    static let maxAssists = 3

    let seed: UInt64
    /// The Record when the game started: beating it turns the full stop `.set`.
    let recordToBeat: Int

    private(set) var board = Board()
    /// The catalog index of each piece on offer, `nil` once used.
    private(set) var tray: [Int?] = []
    private(set) var score = 0
    private(set) var lines = 0
    private(set) var isOver = false
    private(set) var combo = Combo()
    /// Trays dealt so far.
    private(set) var round = 0
    /// Puzzles still to turn into fill and clear.
    private(set) var assists: Int
    /// Seconds of play, as counted by the caller between moves.
    private(set) var playTime: TimeInterval = 0
    /// What the last move scored.
    private(set) var lastGain = 0
    private let avoiding: [Int]
    private var nextPuzzle: TimeInterval
    private var recent: [[Int]] = []
    private var generator: SeededGenerator

    init(seed: UInt64, recordToBeat: Int, avoiding: [Int] = [], assists: Int = 0) {
        self.seed = seed
        self.recordToBeat = recordToBeat
        self.avoiding = avoiding
        self.assists = min(assists, Self.maxAssists)
        generator = SeededGenerator(seed: seed)
        nextPuzzle = TimeInterval(generator.int(in: 120...180))
        refill()
    }

    /// The piece in `slot`, or `nil` once used.
    func piece(in slot: Int) -> Piece? {
        tray[slot].map { Piece.catalog[$0] }
    }

    /// The tone of the piece in `slot`, or `nil` once used.
    func tone(in slot: Int) -> Int? {
        tray[slot].map(Piece.tone(ofShape:))
    }

    /// The pieces still in hand.
    var leftInHand: [Int] {
        tray.compactMap(\.self)
    }

    /// Whether this game has gone past the Record it started with. The first game sets the
    /// Record without beating one: the full stop waits.
    var beatsRecord: Bool {
        recordToBeat > 0 && score > recordToBeat
    }

    /// Puts the piece in `slot` down at `origin`, `elapsed` seconds after the last move; `nil`,
    /// and nothing changes, if it does not fit.
    @discardableResult
    mutating func place(slot: Int, at origin: Cell, elapsed: TimeInterval = 0) -> Placement? {
        guard !isOver, let dropped = piece(in: slot), let placement = board.preview(dropped, at: origin) else { return nil }
        board.apply(placement, tone: tone(in: slot) ?? 0)
        playTime += elapsed
        combo.record(lines: placement.lineCount)
        lastGain = placement.covered.count + Combo.linePoints(lines: placement.lineCount, combo: combo.count)
        if board.filledCount == 0, round > Self.clearBoardFromRound { lastGain += Self.clearBoardPoints }
        score += lastGain
        lines += placement.lineCount
        tray[slot] = nil
        if tray.allSatisfy({ $0 == nil }) { refill() }
        isOver = !tray.indices.contains { piece(in: $0).map(board.hasRoom(for:)) ?? false }
        return placement
    }

    private mutating func refill() {
        round += 1
        let bits = BitBoard(board)
        var pool = Dealer.pool
        if score > Dealer.smallLimit { pool.removeAll(where: Dealer.small.contains) }
        if round <= Self.avoidRounds { pool.removeAll(where: avoiding.contains) }
        if pool.isEmpty { pool = Dealer.pool }

        var chosen: [Int]?
        if playTime >= nextPuzzle {
            nextPuzzle = playTime + TimeInterval(generator.int(in: 30...60))
            if assists > 0 {
                assists -= 1
                chosen = Dealer.fill(pool: pool, on: bits, using: &generator)
            } else {
                chosen = Dealer.hard(pool: pool, on: bits, using: &generator)
            }
        } else if Dealer.isLoop(recent) {
            chosen = Dealer.noLines(pool: pool, on: bits, using: &generator)
        }
        if chosen == nil, generator.int(in: 0...9) >= 5 {
            chosen = Dealer.entropy(pool: pool, on: bits, using: &generator)
        }
        var dealt = chosen ?? Dealer.randomNoDeath(pool: pool, on: bits, using: &generator)
        dealt = Dealer.secured(dealt, pool: pool, on: bits, using: &generator)
        dealt = Dealer.varied(dealt, after: recent.last, pool: pool, on: bits, using: &generator)
        recent = Array((recent + [dealt]).suffix(Dealer.memory))
        tray = dealt
    }
}
