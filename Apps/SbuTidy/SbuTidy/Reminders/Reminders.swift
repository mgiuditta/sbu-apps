import Foundation
import Observation

/// Whether reminders are on, their time, the permission iOS gives, and the plan kept with iOS.
///
/// Off until you turn them on, as in Tody. The plan is made again after every save, at launch
/// and each time the app comes back.
@Observable
final class Reminders {
    private enum Key {
        static let isOn = "reminders.isOn"
        static let minutes = "reminders.minutesAfterMidnight"
    }

    /// Reminders arrive at 9:00 unless you pick another time.
    static let defaultMinutes = 9 * 60

    var isOn: Bool {
        didSet { defaults.set(isOn, forKey: Key.isOn) }
    }
    var minutesAfterMidnight: Int {
        didSet { defaults.set(minutesAfterMidnight, forKey: Key.minutes) }
    }
    private(set) var access: NotificationAccess = .notDetermined

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let center: any ReminderCenter
    /// Bumped by each reschedule, so a plan that waited on iOS never overwrites a newer one.
    @ObservationIgnored private var generation = 0

    init(defaults: UserDefaults = .standard, center: any ReminderCenter = SystemReminderCenter()) {
        self.defaults = defaults
        self.center = center
        isOn = defaults.bool(forKey: Key.isOn)
        let stored = defaults.object(forKey: Key.minutes) as? Int ?? Self.defaultMinutes
        minutesAfterMidnight = (0..<24 * 60).contains(stored) ? stored : Self.defaultMinutes
    }

    /// The reminder time as a date today, for a time picker.
    func time(on day: Date = .now, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60, second: 0, of: day) ?? day
    }

    func setTime(_ time: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: time)
        minutesAfterMidnight = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// Plans every reminder again; asks for permission the first time reminders are on.
    func reschedule(_ chores: [ChoreSnapshot], now: Date = .now, calendar: Calendar = .current) async {
        generation += 1
        let current = generation
        guard isOn else {
            center.replace(with: [])
            access = await center.access()
            return
        }
        access = await center.access()
        if access == .notDetermined {
            access = await center.requestAccess()
        }
        guard current == generation else { return }
        guard access == .allowed else {
            center.replace(with: [])
            return
        }
        center.replace(with: ReminderPlan.reminders(for: chores, hour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60, now: now, calendar: calendar))
    }

    func refreshAccess() async {
        access = await center.access()
    }

    func sendTest() {
        center.sendTest()
    }
}
