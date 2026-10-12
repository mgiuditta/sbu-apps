import Foundation
import UserNotifications

/// Hands the planned reminders to iOS. The only notifications the app ever sends.
enum ReminderScheduler {
    /// Asks for permission; iOS shows the prompt only the first time.
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replaces every pending reminder with `reminders`. Synchronous on purpose: two quick
    /// changes can never interleave and bring back a reminder the newer plan dropped.
    static func replace(with reminders: [PlannedReminder]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = String(localized: "Da fare oggi")
            content.sound = .default
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            // ponytail: a reminder iOS refuses is skipped; the next change plans it again.
            center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }
}
