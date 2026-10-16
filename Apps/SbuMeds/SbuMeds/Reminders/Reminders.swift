import Foundation
import Observation

/// Whether reminders are on, how often an unmarked one comes back, how long "Rimanda" waits,
/// the permission iOS gives, and the plan kept with iOS.
///
/// On by default: reminding is what the app is for. iOS asks for permission when the first
/// medicine with a time is saved. The plan is made again after every save, at launch, each time
/// the app comes back and after each action taken from a notification.
@Observable
final class Reminders {
    private enum Key {
        static let isOn = "reminders.isOn"
        static let repeatMinutes = "reminders.repeatMinutes"
        static let snoozeMinutes = "reminders.snoozeMinutes"
    }

    /// "Ripeti" choices; 0 is never. Medisafe repeats every 10 minutes with no choice.
    static let repeatChoices = [0, 5, 10, 15, 30, 60]
    static let snoozeChoices = [5, 10, 15, 30, 60]
    static let defaultRepeatMinutes = 15
    static let defaultSnoozeMinutes = 10

    var isOn: Bool {
        didSet { defaults.set(isOn, forKey: Key.isOn) }
    }
    var repeatMinutes: Int {
        didSet { defaults.set(repeatMinutes, forKey: Key.repeatMinutes) }
    }
    var snoozeMinutes: Int {
        didSet { defaults.set(snoozeMinutes, forKey: Key.snoozeMinutes) }
    }
    private(set) var access: NotificationAccess = .notDetermined

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let center: any ReminderCenter
    /// Bumped by each reschedule, so a plan that waited on iOS never overwrites a newer one.
    @ObservationIgnored private var generation = 0

    init(defaults: UserDefaults = .standard, center: any ReminderCenter = SystemReminderCenter()) {
        self.defaults = defaults
        self.center = center
        isOn = defaults.object(forKey: Key.isOn) as? Bool ?? true
        let repeats = defaults.object(forKey: Key.repeatMinutes) as? Int ?? Self.defaultRepeatMinutes
        repeatMinutes = Self.repeatChoices.contains(repeats) ? repeats : Self.defaultRepeatMinutes
        let snooze = defaults.object(forKey: Key.snoozeMinutes) as? Int ?? Self.defaultSnoozeMinutes
        snoozeMinutes = Self.snoozeChoices.contains(snooze) ? snooze : Self.defaultSnoozeMinutes
    }

    /// Plans every reminder again; asks for permission once a medicine has a time.
    func reschedule(_ medicines: [MedicineSnapshot], now: Date = .now, calendar: Calendar = .current) async {
        generation += 1
        let current = generation
        let stillToTake = Self.stillToTake(medicines, now: now, calendar: calendar)
        let hasTimes = medicines.contains { $0.schedule.isActive(on: Day(now, calendar: calendar)) }
        guard isOn, hasTimes else {
            center.replace(with: [], snoozeMinutes: snoozeMinutes, stillToTake: stillToTake)
            access = await center.access()
            return
        }
        access = await center.access()
        if access == .notDetermined {
            access = await center.requestAccess()
        }
        guard current == generation else { return }
        guard access == .allowed else {
            center.replace(with: [], snoozeMinutes: snoozeMinutes, stillToTake: stillToTake)
            return
        }
        let plan = ReminderPlan.reminders(for: medicines, now: now, calendar: calendar, repeatMinutes: repeatMinutes)
        center.replace(with: plan, snoozeMinutes: snoozeMinutes, stillToTake: stillToTake)
    }

    /// Today's and yesterday's doses still to take: a delivered reminder about any of them stays.
    static func stillToTake(_ medicines: [MedicineSnapshot], now: Date, calendar: Calendar) -> Set<String> {
        let today = Day(now, calendar: calendar)
        let items = [today.adding(days: -1, in: calendar), today].flatMap { DayPlan(medicines, day: $0, now: now, calendar: calendar).items }
        return Set(items.filter(\.state.isToTake).map(\.key.string))
    }

    func refreshAccess() async {
        access = await center.access()
    }

    func sendTest() {
        center.sendTest()
    }
}
