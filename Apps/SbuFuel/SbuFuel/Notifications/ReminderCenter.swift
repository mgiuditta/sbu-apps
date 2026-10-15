import Foundation

/// Where notifications go: iOS's notification center in the app, a recorder in tests.
protocol ReminderCenter {
    func access() async -> NotificationAccess
    /// Asks for permission; iOS shows its prompt only the first time.
    func requestAccess() async -> NotificationAccess
    /// Replaces every pending notification with `notifications`; those without a date arrive now.
    func replace(with notifications: [PlannedNotification])
}
