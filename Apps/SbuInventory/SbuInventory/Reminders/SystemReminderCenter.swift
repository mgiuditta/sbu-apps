import UserNotifications

/// The iPhone's notification center.
struct SystemReminderCenter: ReminderCenter {
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func isAuthorized() async -> Bool {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    func replace(with reminder: PlannedReminder?) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [PlannedReminder.identifier])
        guard let reminder else { return }
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: PlannedReminder.identifier, content: content, trigger: trigger))
    }
}
