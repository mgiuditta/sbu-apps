/// The streak of moves that complete lines: it survives two moves without a line and ends on the third.
nonisolated struct Combo: Codable, Hashable, Sendable {
    /// Moves without a line that end the streak.
    static let allowedMisses = 3

    private(set) var count = 0
    private(set) var misses = 0

    /// Counts a move that completed `lines` rows and columns.
    mutating func record(lines: Int) {
        if lines > 0 {
            misses = 0
            count += 1
        } else {
            misses += 1
            if misses >= Self.allowedMisses { count = 0 }
        }
    }

    /// Points for completing `lines` together on a streak of `combo`: 10 × combo for one line,
    /// 10 × combo × lines × (lines − 1) for more.
    static func linePoints(lines: Int, combo: Int) -> Int {
        let combo = max(combo, 1)
        switch lines {
        case 0: return 0
        case 1: return 10 * combo
        default: return 10 * combo * lines * (lines - 1)
        }
    }
}
