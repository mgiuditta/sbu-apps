import UserNotifications

/// Shows reminders as banners even with the app open, and hands the actions of a notification
/// (Presa, Saltata, Rimanda) to the app, which marks the doses without being opened.
final class NotificationResponder: NSObject, UNUserNotificationCenterDelegate {
    private nonisolated let handle: @MainActor @Sendable (String, [String]) async -> Void

    init(handle: @escaping @MainActor @Sendable (String, [String]) async -> Void) {
        self.handle = handle
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let action = response.actionIdentifier
        let keys = response.notification.request.content.userInfo[SystemReminderCenter.doseKeysInfo] as? [String] ?? []
        await handle(action, keys)
    }
}
