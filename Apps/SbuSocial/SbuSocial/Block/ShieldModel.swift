import ActivityKit
import DeviceActivity
import FamilyControls
import ManagedSettings
import Observation
import SbuKit
import UserNotifications

/// The Shield's state for Blocco and Sonno: Screen Time permission, the chosen apps, the switch,
/// Sonno, focus, the Limite di tempo and Modalità post. Every change saves to the app group and
/// applies the one answer of `ShieldSettings`, as the monitor extension does.
@Observable
final class ShieldModel {
    private(set) var settings: ShieldSettings
    private(set) var isAuthorized: Bool

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let store = ManagedSettingsStore(named: ShieldSettings.storeName)
    @ObservationIgnored private let center = DeviceActivityCenter()

    init(defaults: UserDefaults = .appGroup) {
        self.defaults = defaults
        settings = ShieldSettings.load(from: defaults)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    var postModeEnd: Date? { settings.postModeEnd }
    var focusEnd: Date? { settings.focusEnd }

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

    // MARK: Sonno

    /// Sonno's settings; every change reschedules the nights. Writable, for bindings from Sonno's controls.
    var sleep: SleepSettings {
        get { settings.sleep }
        set {
            settings.sleep = newValue
            center.stopMonitoring([SleepSettings.activity])
            if newValue.isOn {
                try? center.startMonitoring(SleepSettings.activity, during: newValue.schedule)
            }
            settings.isSleeping = newValue.isOn && settings.isSleeping
            commit()
        }
    }

    // MARK: Focus

    /// Shields the chosen apps from now for `minutes`, whatever the switch says.
    func startFocus(minutes: Int, now: Date = .now) {
        let end = now.addingTimeInterval(TimeInterval(minutes * 60))
        try? center.startMonitoring(ShieldSettings.focusActivity, during: PostMode.oneOff(from: now, to: end))
        settings.focusEnd = end
        commit()
    }

    func endFocus() {
        center.stopMonitoring([ShieldSettings.focusActivity])
        settings.focusEnd = nil
        commit()
    }

    // MARK: Limite di tempo

    /// The Limite di tempo is reached: the native apps are shielded too until midnight.
    func limitReached(now: Date = .now, calendar: Calendar = .current) {
        let day = ShieldSettings.day(now, calendar: calendar)
        guard settings.limitDay != day, let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) else { return }
        try? center.startMonitoring(ShieldSettings.limitActivity, during: PostMode.oneOff(from: now, to: midnight.addingTimeInterval(-1), calendar: calendar))
        settings.limitDay = day
        commit()
    }

    // MARK: Modalità post

    /// Lifts the Shield for 10 minutes, with the countdown on the Lock Screen and in the Dynamic Island.
    func startPostMode(now: Date = .now) {
        guard settings.isShielding(now: now), settings.postModeEnd == nil else { return }
        let end = now.addingTimeInterval(PostMode.duration)
        try? center.startMonitoring(PostMode.activity, during: PostMode.schedule(from: now))
        settings.postModeEnd = end
        commit()
        _ = try? Activity.request(attributes: PostModeAttributes(start: now, end: end),
                                  content: .init(state: .init(), staleDate: end))
    }

    /// Brings the Shield back: when the 10 minutes are up, or early from the Blocco tab.
    func endPostMode() {
        center.stopMonitoring([PostMode.activity])
        settings.postModeEnd = nil
        commit()
        Task {
            for activity in Activity<PostModeAttributes>.activities {
                await activity.end(.init(state: .init(isOver: true), staleDate: nil),
                                   dismissalPolicy: .after(.now.addingTimeInterval(SbuTheme.liveEndDelay)))
            }
        }
    }

    /// When the app comes back: the monitor extension may have changed the Shield meanwhile, or
    /// iOS was late; finished sessions end now.
    func refresh(now: Date = .now) {
        settings = ShieldSettings.load(from: defaults)
        if let end = settings.postModeEnd, end <= now {
            endPostMode()
        } else if settings.postModeEnd == nil, !Activity<PostModeAttributes>.activities.isEmpty {
            endPostMode()
        }
        if let end = settings.focusEnd, end <= now { endFocus() }
        settings.apply(to: store, now: now)
    }

    private func commit() {
        settings.save(to: defaults)
        settings.apply(to: store)
        // The Shield's button and Sonno's warning are notifications: ask the first time either is used.
        if settings.isOn || settings.sleep.isOn {
            Task { _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) }
        }
    }
}
