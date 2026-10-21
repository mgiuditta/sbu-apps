import FamilyControls
import ManagedSettings
import Observation
import UserNotifications

/// The Blocco tab's state: Screen Time permission, the chosen apps, and whether the Shield is on.
@Observable
final class ShieldModel {
    private(set) var settings: ShieldSettings
    private(set) var isAuthorized: Bool

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let store = ManagedSettingsStore(named: ShieldSettings.storeName)

    init(defaults: UserDefaults = .appGroup) {
        self.defaults = defaults
        settings = ShieldSettings.load(from: defaults)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    /// Asks for Screen Time the first time you choose apps, never earlier.
    func authorize() async -> Bool {
        if !isAuthorized {
            try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        }
        return isAuthorized
    }

    func choose(_ selection: FamilyActivitySelection) {
        settings.selection = selection
        if settings.appCount > 0 || !selection.categoryTokens.isEmpty { settings.isOn = true }
        commit()
    }

    /// The Shield's switch.
    var isOn: Bool {
        get { settings.isOn }
        set {
            settings.isOn = newValue
            commit()
        }
    }

    private func commit() {
        settings.save(to: defaults)
        settings.apply(to: store)
        // The Shield's button sends a notification on iOS before 26.5: ask when the Shield first goes on.
        if settings.isOn {
            Task { _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) }
        }
    }
}
