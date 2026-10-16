import ActivityKit
import Foundation

/// The Live Activity of a search, on the Lock Screen and in the Dynamic Island: the device, and
/// how near it sounds.
nonisolated struct SearchActivityAttributes: ActivityAttributes, Hashable, Sendable {
    /// What changes while the search runs.
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        /// From 0 to 100, as the finder's figure.
        var percent: Int
        var warmth: Warmth
        /// Not heard for a few seconds.
        var isLost: Bool
        /// The "found it" moment: the activity says so before it goes.
        var isFound: Bool

        init(percent: Int, warmth: Warmth, isLost: Bool = false, isFound: Bool = false) {
            self.percent = percent
            self.warmth = warmth
            self.isLost = isLost
            self.isFound = isFound
        }

        var proximity: Proximity {
            Proximity(value: percent)
        }
    }

    let deviceName: String
    let systemImage: String
}
