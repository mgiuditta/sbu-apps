import Foundation

/// One local notification to schedule: a habit's title at a moment.
nonisolated struct PlannedReminder: Equatable, Sendable {
    /// Stable per habit, day and time, so rescheduling replaces rather than duplicates.
    let id: String
    let habitID: UUID
    let title: String
    let date: Date
}
