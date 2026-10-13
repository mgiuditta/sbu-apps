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
            if reminder.endsTimer {
                // Default interruption level: time sensitive needs an entitlement the app does not have.
                content.body = String(localized: "\(reminder.title): fatto", comment: "The countdown of a timed habit ended. The habit's title, then 'done'.")
            } else {
                content.title = reminder.title
                content.body = String(localized: "Da fare oggi")
            }
            content.sound = .default
            // To the second: a countdown ends at any second of the minute.
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            // ponytail: a reminder iOS refuses is skipped; the next change plans it again.
            center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }
}
