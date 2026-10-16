import Foundation

/// How the app was launched: by the user, or by screenshots and UI tests on data of their own.
enum Launch {
    static var isSnapshot: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }
    static var isEmptyStore: Bool { UserDefaults.standard.bool(forKey: "SBU_EMPTY_STORE") }
    /// Screenshots and UI tests never touch the device's notifications or widgets.
    static var isDemo: Bool { isSnapshot || isEmptyStore }

    /// Screenshots and UI tests start from the defaults every time: what one run chose (the
    /// filter, reminders on) never leaks into the next.
    static func resetDemoPreferences(_ defaults: UserDefaults = .standard) {
        guard isDemo else { return }
        for key in ["today.filter", "reminders.isOn", "reminders.minutesAfterMidnight"] {
            defaults.removeObject(forKey: key)
        }
    }
}
