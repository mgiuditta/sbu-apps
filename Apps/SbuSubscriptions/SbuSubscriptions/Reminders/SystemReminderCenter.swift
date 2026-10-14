import Foundation
import UserNotifications

/// Hands reminders to iOS. The only notifications the app ever sends, all local.
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

    func replace(with reminders: [PlannedReminder]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.name
            content.body = ReminderText.body(for: reminder)
            content.sound = .default
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            // A reminder iOS refuses is skipped; the next save or launch plans it again.
            center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)))
        }
    }

    func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Sbu Subscriptions")
        content.body = String(localized: "Così arrivano i promemoria prima di ogni rinnovo.")
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))
    }
}
