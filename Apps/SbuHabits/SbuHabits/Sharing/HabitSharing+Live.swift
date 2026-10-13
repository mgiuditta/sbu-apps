import Foundation

extension HabitSharing {
    /// The owner's side in CloudKit. UI tests and screenshots never reach iCloud: Condividi is off
    /// unless a test asks for iCloud to look available with `SBU_HABITS_ICLOUD=available`.
    static func live(model: HabitsModel) -> HabitSharing {
        let environment = ProcessInfo.processInfo.environment
        if environment["SBU_HABITS_FILE"] != nil || UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            return HabitSharing(model: model, outbox: nil, isAvailable: environment["SBU_HABITS_ICLOUD"] == "available")
        }
        return HabitSharing(model: model, outbox: CloudKitSharedHabits())
    }

    /// For previews: iCloud looks available or not, nothing is ever shared.
    static func preview(model: HabitsModel, isAvailable: Bool = true) -> HabitSharing {
        HabitSharing(model: model, outbox: nil, isAvailable: isAvailable)
    }
}
