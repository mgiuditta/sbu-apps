import Foundation
import Observation

/// The reminder time, the permission iOS gives, and the plan kept with iOS.
///
/// The plan is made again after every save, at launch and each time the app comes back, so it
/// always matches the subscriptions and reaches the 64 nearest payments.
@Observable
final class Reminders {
    private enum Key {
        static let minutes = "reminders.minutesAfterMidnight"
    }

    /// Reminders arrive at 9:00 unless you pick another time, as in the 1.0.
    static let defaultMinutes = 9 * 60

    var minutesAfterMidnight: Int {
        didSet { defaults.set(minutesAfterMidnight, forKey: Key.minutes) }
    }
    private(set) var access: NotificationAccess = .notDetermined

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let center: any ReminderCenter
    /// Bumped by each reschedule, so a plan that waited on iOS never overwrites a newer one.
    @ObservationIgnored private var generation = 0

    init(defaults: UserDefaults = .appGroup, center: any ReminderCenter = SystemReminderCenter()) {
        self.defaults = defaults
        self.center = center
        minutesAfterMidnight = defaults.object(forKey: Key.minutes) as? Int ?? Self.defaultMinutes
    }

    /// The reminder time as a date today, for a time picker.
    func time(on day: Date = .now, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60, second: 0, of: day) ?? day
    }

    func setTime(_ time: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: time)
        minutesAfterMidnight = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// Plans every reminder again. Asks for permission the first time a subscription has a reminder.
    func reschedule(_ sources: [ReminderSource], now: Date = .now, calendar: Calendar = .current) async {
        generation += 1
        let current = generation
        access = await center.access()
        let wantsReminders = sources.contains { $0.isActive && $0.daysBefore != nil }
        if access == .notDetermined, wantsReminders {
            access = await center.requestAccess()
        }
        guard current == generation else { return }
        guard access == .allowed else {
            center.replace(with: [])
            return
        }
        center.replace(with: ReminderPlan.reminders(for: sources, hour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60, after: now, calendar: calendar))
    }

    func refreshAccess() async {
        access = await center.access()
    }

    func sendTest() {
        center.sendTest()
    }
}
