import Foundation

/// Shows the "lost" alert: a local notification on an iPhone, a record in tests.
protocol LostNotifier {
    /// Asks to show notifications, the first time; `false` if they are not allowed.
    func requestPermission() async -> Bool

    /// Shows the alert now, with the app open.
    func notifyLost(deviceName: String)

    /// Sets the alert to go off at `date` unless cancelled or set again: with the app in the
    /// background, iOS shows it at the deadline even while the app is suspended.
    func scheduleLost(deviceName: String, at date: Date)

    func cancelScheduledLost()
}
