import Foundation

/// Something the user wants to do on some days, once or several times, with its log of the days it was done.
nonisolated struct Habit: Identifiable, Hashable, Codable, Sendable {
    /// Longest title the form accepts, so it fits a grid cell.
    static let maxTitleLength = 30
    /// The range the form offers for times per day.
    static let timesPerDayRange = 1...20

    let id: UUID
    var title: String
    /// SF Symbol name, one of `HabitSymbol.all`.
    var symbol: String
    /// How many times a day it must be done: 1 for a yes/no habit, 8 for eight glasses of water.
    /// Today's value; past days use `timesPerDay(on:)`.
    private(set) var timesPerDay: Int
    /// Today's schedule; past days use `schedule(on:)`.
    private(set) var schedule: Schedule
    /// Settings replaced by edits, oldest first.
    private(set) var earlier: [HabitSettings] = []
    /// The first day the habit counts: no day before it enters a Serie.
    let createdOn: LogicalDay
    /// How many times it was done on each logical day; missing days are zero.
    var log: [LogicalDay: Int] = [:]
    /// Days skipped with Salta oggi, for example when ill: neutral for every Serie.
    var skipped: Set<LogicalDay> = []
    /// Times of day to be reminded, only on expected days and only while not done.
    var reminders: [ReminderTime] = []

    init(id: UUID = UUID(), title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, createdOn: LogicalDay) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.timesPerDay = timesPerDay
        self.schedule = schedule
        self.createdOn = createdOn
    }

    // Files saved before times per day, schedules, skips, reminders and edits existed: yes/no,
    // every day, nothing skipped, no reminders, never edited.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        symbol = try container.decode(String.self, forKey: .symbol)
        timesPerDay = try container.decodeIfPresent(Int.self, forKey: .timesPerDay) ?? 1
        schedule = try container.decodeIfPresent(Schedule.self, forKey: .schedule) ?? .everyDay
        createdOn = try container.decode(LogicalDay.self, forKey: .createdOn)
        log = try container.decode([LogicalDay: Int].self, forKey: .log)
        skipped = try container.decodeIfPresent(Set<LogicalDay>.self, forKey: .skipped) ?? []
        reminders = try container.decodeIfPresent([ReminderTime].self, forKey: .reminders) ?? []
        earlier = try container.decodeIfPresent([HabitSettings].self, forKey: .earlier) ?? []
    }

    /// The schedule that applied on `day`.
    func schedule(on day: LogicalDay) -> Schedule {
        earlier.first { day < $0.until }?.schedule ?? schedule
    }

    /// The times per day that applied on `day`.
    func timesPerDay(on day: LogicalDay) -> Int {
        earlier.first { day < $0.until }?.timesPerDay ?? timesPerDay
    }

    /// Times it was done on `day`.
    func count(on day: LogicalDay) -> Int {
        log[day, default: 0]
    }

    /// Done on `day` only when every time that day asked for is done.
    func isDone(on day: LogicalDay) -> Bool {
        count(on: day) >= timesPerDay(on: day)
    }

    /// Applies the form's fields from `today` on, trimmed and kept in range. Past days keep the
    /// goal and schedule they had: changing them never rewrites the past.
    /// - Returns: `false`, changing nothing, when the title is blank or no weekday is chosen.
    mutating func update(title: String, symbol: String, timesPerDay: Int, schedule: Schedule, reminders: [ReminderTime] = [], from today: LogicalDay) -> Bool {
        let title = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxTitleLength))
        guard title.isEmpty == false, schedule != .weekdays([]) else { return false }
        self.title = title
        self.symbol = symbol
        self.reminders = Array(Set(reminders)).sorted()
        let newSchedule: Schedule
        let newTimes: Int
        if case .timesPerWeek(let times) = schedule {
            newSchedule = .timesPerWeek(Self.clamp(times, to: Schedule.timesPerWeekRange))
            // A weekly habit counts days, so it is done once a day.
            newTimes = 1
        } else {
            newSchedule = schedule
            newTimes = Self.clamp(timesPerDay, to: Self.timesPerDayRange)
        }
        // Keep the old rules for the days before today, once per day of edits.
        if (newSchedule, newTimes) != (self.schedule, self.timesPerDay), today > createdOn, earlier.last?.until != today {
            earlier.append(HabitSettings(until: today, timesPerDay: self.timesPerDay, schedule: self.schedule))
        }
        self.schedule = newSchedule
        self.timesPerDay = newTimes
        return true
    }

    func isSkipped(on day: LogicalDay) -> Bool {
        skipped.contains(day)
    }

    /// Adds one time on `day`, and takes back a skip; a habit already done stays as it is.
    mutating func mark(on day: LogicalDay) {
        guard isDone(on: day) == false else { return }
        skipped.remove(day)
        log[day, default: 0] += 1
    }

    /// Takes back the last time marked on `day`.
    mutating func undoLast(on day: LogicalDay) {
        let left = count(on: day) - 1
        log[day] = left > 0 ? left : nil
    }

    /// Skips `day`, clearing its marks, or takes the skip back.
    mutating func toggleSkip(on day: LogicalDay) {
        if skipped.remove(day) == nil {
            skipped.insert(day)
            log[day] = nil
        }
    }

    static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
