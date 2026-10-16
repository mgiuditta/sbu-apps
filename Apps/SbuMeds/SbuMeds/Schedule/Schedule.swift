import Foundation

/// When a medicine is due: on which days, at which local times, from a start day to an
/// optional last day. Pure, so every rule is tested without a store.
nonisolated struct Schedule: Hashable, Codable, Sendable {
    static let maxInterval = 30
    static let maxCycleDays = 90

    var frequency: Frequency
    /// The times of each day it is due, sorted, never two at the same minute.
    private(set) var times: [DoseTime]
    /// `.weekdays`: 1 is Sunday, as in `Calendar`.
    var weekdays: Set<Int>
    /// `.everyDays`: days between doses; `.everyHours`: hours between doses.
    var interval: Int
    /// `.cycle`: days on, then days off.
    var cycleOn: Int
    var cycleOff: Int
    var start: Day
    /// Last day included; `nil` for no end.
    var end: Day?

    init(
        frequency: Frequency = .daily,
        times: [DoseTime] = [DoseTime(hour: 8)],
        weekdays: Set<Int> = [],
        interval: Int = 2,
        cycleOn: Int = 21,
        cycleOff: Int = 7,
        start: Day,
        end: Day? = nil
    ) {
        self.frequency = frequency
        self.times = Self.normalized(times)
        self.weekdays = weekdays.filter { (1...7).contains($0) }
        self.interval = min(max(interval, 1), Self.maxInterval)
        self.cycleOn = min(max(cycleOn, 1), Self.maxCycleDays)
        self.cycleOff = min(max(cycleOff, 1), Self.maxCycleDays)
        self.start = start
        self.end = end
    }

    /// Sorted by time; a second entry at the same minute is dropped, so a morning dose can never
    /// be shown twice or swapped with the evening one.
    static func normalized(_ times: [DoseTime]) -> [DoseTime] {
        var seen = Set<Int>()
        return times.sorted().filter { seen.insert($0.minutes).inserted }
    }

    /// The times of "every N hours from `first`" within one day: from 8:00 every 8 hours, 8:00
    /// and 16:00. Midnight belongs to the next day, which starts again at 8:00.
    static func hourlyTimes(first: DoseTime, everyHours hours: Int) -> [DoseTime] {
        let step = min(max(hours, 1), 24) * 60
        return stride(from: first.minutes, to: DoseTime.minutesInDay, by: step).map { DoseTime(minutes: $0, amount: first.amount) }
    }

    mutating func setTimes(_ newTimes: [DoseTime]) {
        times = Self.normalized(newTimes)
    }

    /// The times actually used: hourly schedules are rebuilt from their first time, as needed has none.
    var effectiveTimes: [DoseTime] {
        switch frequency {
        case .asNeeded: []
        case .everyHours: times.first.map { Self.hourlyTimes(first: $0, everyHours: interval) } ?? []
        default: times
        }
    }

    /// Whether the medicine is due at all on `day`.
    func isDue(on day: Day, calendar: Calendar) -> Bool {
        guard day >= start, end.map({ day <= $0 }) ?? true else { return false }
        switch frequency {
        case .daily, .everyHours:
            return true
        case .weekdays:
            return weekdays.contains(day.weekday(in: calendar))
        case .everyDays:
            return start.days(to: day, in: calendar) % interval == 0
        case .cycle:
            return start.days(to: day, in: calendar) % (cycleOn + cycleOff) < cycleOn
        case .asNeeded:
            return false
        }
    }

    /// The doses due on `day`, earliest first.
    func times(on day: Day, calendar: Calendar) -> [DoseTime] {
        isDue(on: day, calendar: calendar) ? effectiveTimes : []
    }

    /// Whether the schedule can still have a dose on or after `day`.
    func isActive(on day: Day) -> Bool {
        frequency != .asNeeded && (end.map { day <= $0 } ?? true)
    }

    /// For the cycle: whether `day` is in the days on, and which day of the phase it is (1-based).
    func cyclePhase(on day: Day, calendar: Calendar) -> (isOn: Bool, dayOfPhase: Int)? {
        guard frequency == .cycle, day >= start else { return nil }
        let position = start.days(to: day, in: calendar) % (cycleOn + cycleOff)
        return position < cycleOn ? (true, position + 1) : (false, position - cycleOn + 1)
    }
}
