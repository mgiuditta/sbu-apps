import Foundation
import UserNotifications

/// Hands the planned reminders to iOS. The only notifications the app ever sends.
enum ReminderScheduler {
    /// Asks for permission; iOS shows the prompt only the first time.
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Whether the user said no to notifications, here or in Impostazioni.
    static func isDenied() async -> Bool {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .denied
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
                content.body = String(localized: "\(reminder.title): fatta", comment: "A habit is done: its countdown ended, or Salute marked it. The habit's title, then 'done', agreeing with 'abitudine' (feminine).")
            } else {
                content.title = reminder.title
                content.body = String(localized: "Da fare oggi")
            }
            content.sound = notificationSound(reminder.sound)
            if reminder.isTimeSensitive {
                content.interruptionLevel = .timeSensitive
            }
            // To the second: a countdown ends at any second of the minute.
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            // ponytail: a reminder iOS refuses is skipped; the next change plans it again.
            center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }

    /// Says right away that Salute marked `habits` done: "<Titolo>: fatta". Delivered at once,
    /// so it never takes a place of the 64 pending.
    static func announceHealthMarks(_ habits: [Habit]) {
        let center = UNUserNotificationCenter.current()
        for habit in habits {
            let content = UNMutableNotificationContent()
            content.body = String(localized: "\(habit.title): fatta", comment: "A habit is done: its countdown ended, or Salute marked it. The habit's title, then 'done', agreeing with 'abitudine' (feminine).")
            content.sound = notificationSound(habit.notificationStyle.sound)
            center.add(UNNotificationRequest(identifier: "\(habit.id)-health", content: content, trigger: nil))
        }
    }

    private static func notificationSound(_ sound: ReminderSound) -> UNNotificationSound? {
        switch sound {
        case .standard: .default
        case .silent: nil
        case .carta, .punto: sound.fileName.map { UNNotificationSound(named: UNNotificationSoundName($0)) }
        }
    }
}
