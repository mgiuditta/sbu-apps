import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

/// What the Shield covers and why it is up now, shared by the app and its Screen Time extensions
/// through the app group. Every change goes through `apply(to:now:)`, so the app and the
/// extensions always agree on one answer.
nonisolated struct ShieldSettings: Codable, Equatable {
    var selection = FamilyActivitySelection()
    /// The switch in Blocco.
    var isOn = false
    var sleep = SleepSettings()
    /// Inside tonight's Sonno, set by the monitor extension.
    var isSleeping = false
    /// The running focus session's end.
    var focusEnd: Date?
    /// The day the Limite di tempo was reached, `yyyy-M-d`: the apps stay shielded until midnight.
    var limitDay: String?
    /// The running Modalità post's end: the Shield is down until then, whatever else holds it up.
    var postModeEnd: Date?

    /// The one store every part of the app writes the Shield to.
    static var storeName: ManagedSettingsStore.Name { .init("shield") }
    static var focusActivity: DeviceActivityName { .init("focus") }
    static var limitActivity: DeviceActivityName { .init("limit") }
    static let focusLengths = [25, 50, 90]

    var appCount: Int {
        selection.applicationTokens.count
    }

    /// Why the Shield is up now, if it is.
    func isShielding(now: Date, calendar: Calendar = .current) -> Bool {
        if let postModeEnd, postModeEnd > now { return false }
        if isOn || isSleeping { return true }
        if let focusEnd, focusEnd > now { return true }
        return limitDay == Self.day(now, calendar: calendar)
    }

    static func day(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    static func load(from defaults: UserDefaults) -> ShieldSettings {
        defaults.data(forKey: "shield").flatMap { try? JSONDecoder().decode(ShieldSettings.self, from: $0) } ?? ShieldSettings()
    }

    func save(to defaults: UserDefaults) {
        defaults.set(try? JSONEncoder().encode(self), forKey: "shield")
    }

    /// Covers the chosen apps and categories while the Shield is up (at night without the apps
    /// you left out), or lifts it.
    func apply(to store: ManagedSettingsStore, now: Date = .now) {
        guard isShielding(now: now) else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            return
        }
        var apps = selection.applicationTokens
        if isSleeping { apps.subtract(sleep.excluded.applicationTokens) }
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens, except: isSleeping ? sleep.excluded.applicationTokens : [])
    }
}
