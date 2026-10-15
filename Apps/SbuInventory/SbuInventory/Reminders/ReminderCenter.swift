/// Where the "Da ricomprare" notification is handed over: the system's center, or a silent one for tests and screenshots.
protocol ReminderCenter: Sendable {
    /// Asks to show notifications; `true` when allowed.
    func requestAuthorization() async -> Bool
    /// Whether notifications are allowed right now.
    func isAuthorized() async -> Bool
    /// Replaces the waiting notification with `reminder`, or removes it when `nil`.
    func replace(with reminder: PlannedReminder?) async
}
