import Foundation

extension HabitsSync {
    /// For previews: iCloud looks available, nothing is ever synced.
    static func preview(model: HabitsModel, isAvailable: Bool = true) -> HabitsSync {
        HabitsSync(
            model: model,
            remote: nil,
            base: HabitsStore(url: .temporaryDirectory.appending(path: "icloud-base-preview.json")),
            preferences: nil,
            account: { isAvailable ? Data() : nil }
        )
    }
}
