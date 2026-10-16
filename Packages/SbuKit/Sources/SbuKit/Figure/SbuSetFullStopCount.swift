import SwiftUI

/// Counts the `.set` full stops under a view: the design system allows one per screen.
///
/// Every `.set` `SbuFullStop` reports 1; the shells read the sum on their content and, in DEBUG,
/// log a warning when it is above `allowed`.
nonisolated struct SbuSetFullStopCount: PreferenceKey {
    /// The most `.set` full stops a screen or widget may show.
    static let allowed = 1

    static let defaultValue = 0

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }

    /// Whether a screen with `count` `.set` full stops follows the design system.
    static func isAllowed(_ count: Int) -> Bool {
        count <= allowed
    }
}
