import Foundation

/// One notification to hand to iOS: the chores that turn due on a day, said at the chosen time.
nonisolated struct PlannedReminder: Equatable, Sendable {
    /// When the notification arrives.
    let fireDate: Date
    /// The chores that turn due that day, the dirtiest first.
    let choreNames: [String]

    /// Stable for the same day, so a new plan replaces rather than duplicates.
    var identifier: String {
        "tidy-\(Int(fireDate.timeIntervalSince1970))"
    }
}
