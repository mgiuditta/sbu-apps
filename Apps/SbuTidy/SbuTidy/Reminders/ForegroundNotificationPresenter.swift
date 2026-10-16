import UserNotifications

/// Shows a reminder as a banner even when the app is open, as it would be anywhere else.
final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
