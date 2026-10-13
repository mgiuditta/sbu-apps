import Foundation
import Observation

/// The phase alerts the user chose, saved on this iPhone, and the plan kept with iOS.
///
/// Permission is asked only when an alert is turned on. The plan is made again every time the
/// app comes to the foreground, so it always reaches about a year ahead.
@Observable
final class PhaseAlerts {
    private enum Key {
        static let phases = "phaseAlerts.phases"
        static let minutes = "phaseAlerts.minutesAfterMidnight"
    }

    /// Alerts arrive at 9:00 unless the user picks another time: the day starts with the news.
    static let defaultMinutes = 9 * 60

    var selection: PhaseSelection
    /// Minutes after midnight the alert arrives, on the day of the phase.
    var minutesAfterMidnight: Int
    private(set) var access: NotificationAccess = .notDetermined

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let center: any PhaseAlertCenter

    /// Whether to tell the user that iOS blocks the alerts they turned on.
    var isBlocked: Bool {
        selection.isEmpty == false && access == .denied
    }

    init(defaults: UserDefaults = .standard, center: any PhaseAlertCenter = SystemPhaseAlertCenter()) {
        self.defaults = defaults
        self.center = center
        let saved = defaults.stringArray(forKey: Key.phases) ?? []
        selection = PhaseSelection(Set(PrincipalPhase.allCases.filter { saved.contains($0.storageKey) }))
        minutesAfterMidnight = defaults.object(forKey: Key.minutes) as? Int ?? Self.defaultMinutes
    }

    /// The alert time as a date today, for a time picker.
    func time(on day: Date = .now, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60, second: 0, of: day) ?? day
    }

    /// Takes the hour and minute of a picked time.
    func setTime(_ time: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: time)
        minutesAfterMidnight = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// Saves a change of phases or time; turning a phase on asks for permission the first time.
    func settingsChanged(from previous: PhaseSelection? = nil, now: Date = .now, calendar: Calendar = .current) async {
        save()
        if let previous, selection.adds(to: previous), access != .allowed {
            access = await center.requestAccess()
        }
        await reschedule(now: now, calendar: calendar)
    }

    /// Plans the alerts again from now, if iOS lets the app send them.
    func reschedule(now: Date = .now, calendar: Calendar = .current) async {
        access = await center.access()
        guard access == .allowed, selection.isEmpty == false else {
            center.replace(with: [])
            return
        }
        let hour = minutesAfterMidnight / 60, minute = minutesAfterMidnight % 60
        center.replace(with: PhaseAlertPlan.alerts(for: selection.phases, hour: hour, minute: minute, after: now, calendar: calendar))
    }

    private func save() {
        defaults.set(PrincipalPhase.allCases.filter { selection[$0] }.map(\.storageKey), forKey: Key.phases)
        defaults.set(minutesAfterMidnight, forKey: Key.minutes)
    }
}
