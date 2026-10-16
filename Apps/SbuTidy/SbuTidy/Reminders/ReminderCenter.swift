import Foundation

/// Where reminders go: iOS's notification center in the app, a recorder in tests.
protocol ReminderCenter {
    func access() async -> NotificationAccess
    /// Asks for permission; iOS shows its prompt only the first time.
    func requestAccess() async -> NotificationAccess
    /// Replaces every pending notification with `reminders`. Synchronous, so two quick saves
    /// never interleave and bring back a reminder the newer plan dropped.
    func replace(with reminders: [PlannedReminder])
    /// A sample reminder now, to check notifications arrive.
    func sendTest()
}
