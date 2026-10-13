import Foundation

/// The Abitudini condivise received on this iPhone: a file of their own in the App Group, never in
/// `habits.json`, so they never sync, export or count as the user's habits.
nonisolated struct ReceivedHabitsFile: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = currentVersion
    var habits: [ReceivedHabit] = []
    /// Shares the user removed whose leaving iCloud has not confirmed yet: never shown again, and
    /// left again at the next refresh.
    var removed: Set<String> = []
}
