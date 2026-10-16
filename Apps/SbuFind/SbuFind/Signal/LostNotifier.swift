/// Shows the "lost" alert: a local notification on an iPhone, a record in tests.
protocol LostNotifier {
    /// Asks to show notifications, the first time; `false` if they are not allowed.
    func requestPermission() async -> Bool

    func notifyLost(deviceName: String)
}
