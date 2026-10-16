import Foundation

/// How the app was launched: by the user, or by screenshots and UI tests on data of their own.
enum Launch {
    static var isSnapshot: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }
    static var isEmptyStore: Bool { UserDefaults.standard.bool(forKey: "SBU_EMPTY_STORE") }
    /// Screenshots and UI tests never touch the device's notifications or widgets.
    static var isDemo: Bool { isSnapshot || isEmptyStore }
}
