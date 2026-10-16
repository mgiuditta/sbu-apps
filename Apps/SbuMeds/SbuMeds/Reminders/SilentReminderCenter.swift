/// For screenshots and UI tests: never asks, never touches the notifications on the device.
struct SilentReminderCenter: ReminderCenter {
    func access() async -> NotificationAccess { .notDetermined }
    func requestAccess() async -> NotificationAccess { .notDetermined }
    func replace(with reminders: [PlannedReminder], snoozeMinutes: Int, stillToTake: Set<String>) {}
    func sendTest() {}
}
