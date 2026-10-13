import Foundation

extension ReceivedHabits {
    /// The habits shared with this user, from CloudKit. UI tests and screenshots never reach
    /// iCloud; a UI test can start with one received habit with `SBU_HABITS_SHARED_DEMO=1`.
    static func live() -> ReceivedHabits {
        let environment = ProcessInfo.processInfo.environment
        let store = ReceivedHabitsStore.shared
        if environment["SBU_HABITS_FILE"] != nil || environment["SBU_HABITS_SHARED_FILE"] != nil || UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            if environment["SBU_HABITS_SHARED_DEMO"] == "1" {
                try? store.save(.demo(today: LogicalDay(.now)))
            }
            return ReceivedHabits(store: store, inbox: nil)
        }
        return ReceivedHabits(store: store, inbox: CloudKitSharedHabits(), preferences: .standard)
    }

    /// For previews: one habit someone shares, in a throwaway file.
    static var preview: ReceivedHabits {
        let store = ReceivedHabitsStore(url: .temporaryDirectory.appending(path: "received-preview-\(UUID().uuidString).json"))
        try? store.save(.demo(today: LogicalDay(.now)))
        return ReceivedHabits(store: store, inbox: nil)
    }
}
