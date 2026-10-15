/// For screenshots, UI tests and unit tests: never asks, records what it would have sent.
final class SilentReminderCenter: ReminderCenter {
    var stubbedAccess: NotificationAccess
    private(set) var sent: [PlannedNotification] = []

    init(access: NotificationAccess = .notDetermined) {
        stubbedAccess = access
    }

    func access() async -> NotificationAccess { stubbedAccess }
    func requestAccess() async -> NotificationAccess { stubbedAccess }
    func replace(with notifications: [PlannedNotification]) {
        sent = notifications
    }
}
