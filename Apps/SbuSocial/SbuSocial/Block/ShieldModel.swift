import ActivityKit
import DeviceActivity
import FamilyControls
import ManagedSettings
import Observation
import SbuKit
import UserNotifications

/// The Blocco tab's state: Screen Time permission, the chosen apps, and whether the Shield is on.
@Observable
final class ShieldModel {
    private(set) var settings: ShieldSettings
    private(set) var isAuthorized: Bool
    /// When the running Modalità post ends; `nil` when the Shield is down only by your switch, or up.
    private(set) var postModeEnd: Date?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let store = ManagedSettingsStore(named: ShieldSettings.storeName)

    init(defaults: UserDefaults = .appGroup) {
        self.defaults = defaults
        settings = ShieldSettings.load(from: defaults)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        postModeEnd = PostMode.end(in: defaults)
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

    /// Lifts the Shield for 10 minutes, with the countdown on the Lock Screen and in the Dynamic Island.
    func startPostMode(now: Date = .now) {
        guard settings.isOn, postModeEnd == nil else { return }
        let end = now.addingTimeInterval(PostMode.duration)
        try? DeviceActivityCenter().startMonitoring(PostMode.activity, during: PostMode.schedule(from: now))
        ShieldSettings().apply(to: store)
        postModeEnd = end
        PostMode.setEnd(end, in: defaults)
        _ = try? Activity.request(attributes: PostModeAttributes(start: now, end: end),
                                  content: .init(state: .init(), staleDate: end))
    }

    /// Brings the Shield back: when the 10 minutes are up, or early from the Blocco tab.
    func endPostMode() {
        DeviceActivityCenter().stopMonitoring([PostMode.activity])
        postModeEnd = nil
        PostMode.setEnd(nil, in: defaults)
        settings.apply(to: store)
        Task {
            for activity in Activity<PostModeAttributes>.activities {
                await activity.end(.init(state: .init(isOver: true), staleDate: nil), dismissalPolicy: .after(.now.addingTimeInterval(SbuTheme.liveEndDelay)))
            }
        }
    }

    /// When the app comes back: the monitor extension may have brought the Shield back already,
    /// or iOS was late; either way the 10 minutes are over.
    func refresh(now: Date = .now) {
        postModeEnd = PostMode.end(in: defaults)
        if let end = postModeEnd, end <= now {
            endPostMode()
        } else if postModeEnd == nil, !Activity<PostModeAttributes>.activities.isEmpty {
            endPostMode()
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
