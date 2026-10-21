import ActivityKit
import Foundation

/// Modalità post's Live Activity: the countdown to the Shield's return.
nonisolated struct PostModeAttributes: ActivityAttributes, Hashable, Sendable {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        /// The Shield is back: the full stop is set for the last 4 seconds.
        var isOver = false
    }

    let start: Date
    let end: Date
}
