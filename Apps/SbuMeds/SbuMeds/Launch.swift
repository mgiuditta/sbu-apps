import Foundation

/// How the app was launched: by the user, or by screenshots and UI tests on data of their own.
enum Launch {
    static var isSnapshot: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }
    static var isEmptyStore: Bool { UserDefaults.standard.bool(forKey: "SBU_EMPTY_STORE") }
    /// Screenshots and UI tests never touch the device's notifications or widgets.
    static var isDemo: Bool { isSnapshot || isEmptyStore }

    /// Screenshots stop the clock at 10:12 today: the morning taken, the rest of the day to come,
    /// whatever time they run at.
    static let snapshotNow: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 10, minute: 12, second: 0, of: .now) ?? .now
    }()

    /// Screenshots and UI tests start from the defaults every time: what one run chose (the
    /// person, reminder settings) never leaks into the next.
    static func resetDemoPreferences(_ defaults: UserDefaults = .standard) {
        guard isDemo else { return }
        for key in ["today.person", "reminders.isOn", "reminders.repeatMinutes", "reminders.snoozeMinutes"] {
            defaults.removeObject(forKey: key)
        }
    }
}
