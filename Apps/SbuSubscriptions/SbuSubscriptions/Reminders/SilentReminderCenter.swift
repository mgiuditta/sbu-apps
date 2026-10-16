/// For screenshots and UI tests: never asks, never touches the notifications on the device.
struct SilentReminderCenter: ReminderCenter {
    /// What it answers about permission; a flow test sets `.denied` to see the warning in the form.
    var answer = NotificationAccess.notDetermined

    func access() async -> NotificationAccess { answer }
    func requestAccess() async -> NotificationAccess { answer }
    func replace(with reminders: [PlannedReminder]) {}
    func sendTest() {}
}
