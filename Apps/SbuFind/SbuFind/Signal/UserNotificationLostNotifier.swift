import UserNotifications

/// The "lost" alert as a local notification, shown as a banner also while Sbu Find is open.
/// Made and shown on the iPhone: nothing goes through a server.
final class UserNotificationLostNotifier: NSObject, LostNotifier, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func notifyLost(deviceName: String) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "\(deviceName) non si sente più")
        content.body = String(localized: "Sbu Find non lo sente da 15 secondi: forse l'hai lasciato indietro. Torna sui tuoi passi e cercalo.")
        content.sound = .default
        let request = UNNotificationRequest(identifier: "lost", content: content, trigger: nil)
        center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
