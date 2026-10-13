import Foundation

/// One local notification to schedule: a habit's title at a moment, or the end of its countdown.
nonisolated struct PlannedReminder: Equatable, Sendable {
    /// Stable per habit, day and time, so rescheduling replaces rather than duplicates.
    let id: String
    let habitID: UUID
    let title: String
    let date: Date
    /// The end of an Abitudine a tempo's countdown, not a reminder to do it.
    var endsTimer = false
    /// Comes through a Focus that allows Time Sensitive notifications.
    var isTimeSensitive = false
    var sound = ReminderSound.standard
}
