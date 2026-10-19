import Foundation

/// The difficulty proposed for the next game, as the original works it out.
///
/// The player's level comes from the wins of the last seven days, at least three of them, or it
/// is Hard. The level is the most won difficulty, or the hardest one won, if it was won at least
/// 0.8 times as often. Then the proposal is drawn around the level, mostly the level itself.
nonisolated enum DifficultyAdvisor {
    static let window: TimeInterval = 7 * 24 * 60 * 60
    static let minimumWins = 3
    static let hardestShare = 0.8

    static func level(wins: [Win], now: Date) -> Difficulty {
        let recent = wins.filter { now.timeIntervalSince($0.date) <= window && $0.date <= now }
        guard recent.count >= minimumWins else { return .fallback }
        let counts = Dictionary(grouping: recent, by: \.difficulty).mapValues(\.count)
        // ponytail: on a tie the easier difficulty counts as the most won; the original's tie-break is not known.
        let mostWon = counts.max { $0.value < $1.value || ($0.value == $1.value && $0.key > $1.key) }!.key
        let hardest = counts.keys.max()!
        return Double(counts[hardest]!) / Double(counts[mostWon]!) < hardestShare ? mostWon : hardest
    }

    /// `draw` is a number in 0..<1.
    static func proposal(wins: [Win], now: Date, draw: Double) -> Difficulty {
        let weights = level(wins: wins, now: now).proposalWeights
        let total = weights.values.reduce(0, +)
        var cumulative = 0.0
        for difficulty in Difficulty.allCases {
            cumulative += weights[difficulty] ?? 0
            if cumulative > draw * total { return difficulty }
        }
        return .fallback
    }
}
