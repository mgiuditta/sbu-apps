import FamilyControls
import Foundation
import ManagedSettings

/// What the Shield covers, shared by the app and its Screen Time extensions through the app group.
nonisolated struct ShieldSettings: Codable, Equatable {
    var selection = FamilyActivitySelection()
    var isOn = false

    /// The one store every part of the app writes the Shield to.
    static var storeName: ManagedSettingsStore.Name { .init("shield") }

    var appCount: Int {
        selection.applicationTokens.count
    }

    static func load(from defaults: UserDefaults) -> ShieldSettings {
        defaults.data(forKey: "shield").flatMap { try? JSONDecoder().decode(ShieldSettings.self, from: $0) } ?? ShieldSettings()
    }

    func save(to defaults: UserDefaults) {
        defaults.set(try? JSONEncoder().encode(self), forKey: "shield")
    }

    /// Covers the chosen apps and categories, or lifts the Shield when it is off.
    func apply(to store: ManagedSettingsStore) {
        guard isOn else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            return
        }
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    }
}
