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
    var timesPerDay: Int
    var schedule: Schedule
    /// The first day the habit counts: no day before it enters a Serie.
    let createdOn: LogicalDay
    /// How many times it was done on each logical day; missing days are zero.
    var log: [LogicalDay: Int] = [:]
    /// Days skipped with Salta oggi, for example when ill: neutral for every Serie.
    var skipped: Set<LogicalDay> = []

    init(id: UUID = UUID(), title: String, symbol: String, timesPerDay: Int = 1, schedule: Schedule = .everyDay, createdOn: LogicalDay) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.timesPerDay = timesPerDay
        self.schedule = schedule
        self.createdOn = createdOn
    }

    // Files saved before times per day, schedules and skips existed: yes/no, every day, nothing skipped.
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
    }

    /// Times it was done on `day`.
    func count(on day: LogicalDay) -> Int {
        log[day, default: 0]
    }

    /// Done on `day` only when every time of the day is done.
    func isDone(on day: LogicalDay) -> Bool {
        count(on: day) >= timesPerDay
    }

    /// Applies the form's fields, trimmed and kept in range. Leaves the log as it is: changing
    /// the schedule never rewrites the past.
    /// - Returns: `false`, changing nothing, when the title is blank or no weekday is chosen.
    mutating func update(title: String, symbol: String, timesPerDay: Int, schedule: Schedule) -> Bool {
        let title = String(title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxTitleLength))
        guard title.isEmpty == false, schedule != .weekdays([]) else { return false }
        self.title = title
        self.symbol = symbol
        if case .timesPerWeek(let times) = schedule {
            self.schedule = .timesPerWeek(Self.clamp(times, to: Schedule.timesPerWeekRange))
            // A weekly habit counts days, so it is done once a day.
            self.timesPerDay = 1
        } else {
            self.schedule = schedule
            self.timesPerDay = Self.clamp(timesPerDay, to: Self.timesPerDayRange)
        }
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

    private static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
