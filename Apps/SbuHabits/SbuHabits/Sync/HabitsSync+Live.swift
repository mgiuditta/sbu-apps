import Foundation

extension HabitsSync {
    /// The app's sync with the user's iCloud. UI tests and screenshots run on a throwaway file:
    /// they never touch iCloud, and keep the switch in memory. A UI test can ask for iCloud to
    /// look available with `SBU_HABITS_ICLOUD=available`.
    static func live(model: HabitsModel) -> HabitsSync {
        let environment = ProcessInfo.processInfo.environment
        if environment["SBU_HABITS_FILE"] != nil || UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            let isAvailable = environment["SBU_HABITS_ICLOUD"] == "available"
            return HabitsSync(
                model: model,
                remote: nil,
                base: HabitsStore(url: .temporaryDirectory.appending(path: "icloud-base-\(UUID().uuidString).json")),
                preferences: nil,
                account: { isAvailable ? NSString(string: "uitest") : nil }
            )
        }
        return HabitsSync(
            model: model,
            remote: ICloudHabitsFile(),
            // On this iPhone only, outside the App Group: the widget never needs it.
            base: HabitsStore(url: .applicationSupportDirectory.appending(path: "icloud-last-sync.json")),
            preferences: .standard,
            account: currentAccount,
            watcher: ICloudWatcher()
        )
    }

    /// The iCloud account signed in with iCloud Drive on, as iCloud's opaque token, or `nil`.
    /// Quick to read on the main actor, unlike the container.
    private static func currentAccount() -> NSObject? {
        FileManager.default.ubiquityIdentityToken as? NSObject
    }
}
