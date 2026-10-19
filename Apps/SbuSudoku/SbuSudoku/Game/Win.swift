import Foundation

/// A game won, kept a week to work out the difficulty to propose.
nonisolated struct Win: Codable, Hashable, Sendable {
    let date: Date
    let difficulty: Difficulty
}
