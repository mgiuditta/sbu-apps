import Foundation
import UserNotifications

/// Hands service reminders to iOS. The only notifications the app ever sends, all local.
struct SystemReminderCenter: ReminderCenter {
    func access() async -> NotificationAccess {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .denied: .denied
        default: .allowed
        }
    }

    func requestAccess() async -> NotificationAccess {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        return await access()
    }

    func replace(with notifications: [PlannedNotification]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            let trigger = notification.fireDate.map {
                UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: $0), repeats: false)
            }
            // A request iOS refuses is skipped; the next save or launch plans it again.
            center.add(UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger))
        }
    }
}
