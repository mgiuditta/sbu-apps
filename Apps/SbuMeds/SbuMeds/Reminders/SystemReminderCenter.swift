import Foundation
import UserNotifications

/// Hands reminders to iOS. The only notifications the app ever sends, all local, planned on the iPhone.
struct SystemReminderCenter: ReminderCenter {
    nonisolated static let doseCategory = "dose"
    nonisolated static let takenAction = "taken"
    nonisolated static let skippedAction = "skipped"
    nonisolated static let snoozeAction = "snooze"
    nonisolated static let doseKeysInfo = "doses"

    func access() async -> NotificationAccess {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .denied: .denied
        default: .allowed
        }
    }

    func requestAccess() async -> NotificationAccess {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        return await access()
    }

    func replace(with reminders: [PlannedReminder], snoozeMinutes: Int, stillToTake: Set<String>) {
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([Self.category(snoozeMinutes: snoozeMinutes)])
        center.removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        let showsPerson = Set(reminders.map(\.personID)).count > 1
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = ReminderText.title(for: reminder, showsPerson: showsPerson, calendar: calendar)
            content.body = ReminderText.body(for: reminder, showsPerson: showsPerson)
            content.sound = .default
            if case .doses = reminder.kind {
                content.categoryIdentifier = Self.doseCategory
                content.userInfo = [Self.doseKeysInfo: reminder.doseKeys]
                // Repeats replace the one before in Notification Center instead of piling up.
                content.threadIdentifier = PlannedReminder.groupIdentifier(personID: reminder.personID, dueDate: reminder.dueDate)
            }
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.fireDate)
            // A reminder iOS refuses is skipped; the next change or launch plans it again.
            center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)))
        }
        Task {
            // Delivered reminders whose doses are all marked go, as Medisafe's users asked.
            let delivered = await center.deliveredNotifications()
            let done = delivered.filter { notification in
                guard let keys = notification.request.content.userInfo[Self.doseKeysInfo] as? [String] else { return false }
                return stillToTake.isDisjoint(with: keys)
            }
            center.removeDeliveredNotifications(withIdentifiers: done.map(\.request.identifier))
        }
    }

    func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Ore \(Date.now.formatted(.dateTime.hour().minute()))")
        content.body = String(localized: "Così arriva un promemoria: Presa, Saltata o Rimanda, anche dalla schermata di blocco.")
        content.sound = .default
        content.categoryIdentifier = Self.doseCategory
        // Delivered now, never pending: a new plan clears the queue and would drop it.
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content, trigger: nil))
    }

    /// Presa, Saltata, Rimanda: from the banner and the Lock Screen, without opening the app.
    static func category(snoozeMinutes: Int) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: doseCategory,
            actions: [
                UNNotificationAction(identifier: takenAction, title: String(localized: "Presa"), options: [], icon: UNNotificationActionIcon(systemImageName: "checkmark")),
                UNNotificationAction(identifier: skippedAction, title: String(localized: "Saltata"), options: [], icon: UNNotificationActionIcon(systemImageName: "minus.circle")),
                UNNotificationAction(identifier: snoozeAction, title: String(localized: "Rimanda di \(snoozeMinutes) min"), options: [], icon: UNNotificationActionIcon(systemImageName: "clock.arrow.circlepath")),
            ],
            intentIdentifiers: [],
            options: []
        )
    }
}
