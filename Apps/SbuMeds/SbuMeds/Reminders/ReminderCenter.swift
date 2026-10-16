import Foundation

/// Where reminders go: iOS's notification center in the app, a recorder in tests.
protocol ReminderCenter {
    func access() async -> NotificationAccess
    /// Asks for permission; iOS shows its prompt only the first time.
    func requestAccess() async -> NotificationAccess
    /// Replaces every pending notification with `reminders`, and clears the delivered ones whose
    /// doses are all marked. Synchronous, so two quick saves never interleave and bring back a
    /// reminder the newer plan dropped.
    func replace(with reminders: [PlannedReminder], snoozeMinutes: Int, stillToTake: Set<String>)
    /// A sample reminder now, to check notifications arrive.
    func sendTest()
}
