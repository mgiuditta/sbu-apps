/// A center that never touches the iPhone's notifications: UI tests and screenshots run on made-up data.
struct SilentReminderCenter: ReminderCenter {
    func requestAuthorization() async -> Bool { true }
    func isAuthorized() async -> Bool { true }
    func replace(with reminder: PlannedReminder?) async {}
}
