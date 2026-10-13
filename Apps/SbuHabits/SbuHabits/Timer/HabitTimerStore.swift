import Foundation

/// Keeps the running countdown in the App Group's defaults, outside `habits.json`: it is
/// transient, never exported, and the widget reads it to keep its notification planned.
nonisolated struct HabitTimerStore {
    /// The App Group's defaults; UI tests get a key of their own, next to their throwaway file.
    static var shared: HabitTimerStore {
        let defaults = UserDefaults(suiteName: HabitsStore.appGroup) ?? .standard
        if let name = ProcessInfo.processInfo.environment["SBU_HABITS_FILE"] {
            return HabitTimerStore(defaults: defaults, key: "habitTimer-\(name)")
        }
        return HabitTimerStore(defaults: defaults, key: "habitTimer")
    }

    let defaults: UserDefaults
    let key: String

    /// The countdown saved, or `nil` when none runs or it cannot be read.
    func load() -> HabitTimer? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(HabitTimer.self, from: $0) }
    }

    /// Saves `timer`, or forgets the saved one with `nil`.
    func save(_ timer: HabitTimer?) {
        if let timer, let data = try? JSONEncoder().encode(timer) {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
