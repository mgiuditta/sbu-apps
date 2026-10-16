import UserNotifications

/// The "lost" alert as a local notification, shown as a banner also while Sbu Find is open.
/// Made and shown on the iPhone: nothing goes through a server.
final class UserNotificationLostNotifier: NSObject, LostNotifier, UNUserNotificationCenterDelegate {
    /// One scheduled alert at a time: setting it again replaces the pending one.
    private static let scheduledID = "lost.scheduled"

    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func notifyLost(deviceName: String) {
        center.add(UNNotificationRequest(identifier: "lost", content: Self.content(deviceName), trigger: nil))
    }

    func scheduleLost(deviceName: String, at date: Date) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
        center.add(UNNotificationRequest(identifier: Self.scheduledID, content: Self.content(deviceName), trigger: trigger))
    }

    func cancelScheduledLost() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.scheduledID])
    }

    private static func content(_ deviceName: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "\(deviceName) non si sente più")
        content.body = String(localized: "Sbu Find non lo sente più: forse l'hai lasciato indietro. Torna sui tuoi passi e cercalo.")
        content.sound = .default
        return content
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
