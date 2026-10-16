import Foundation

/// A calendar day without a time zone: 16 October 2026 is the same day in Rome and in New York.
///
/// Doses are fixed to a day and a local time, so flying to another time zone never moves them:
/// 8:00 stays 8:00 where you are.
nonisolated struct Day: Hashable, Comparable, Codable, Sendable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The day a moment falls on in `calendar`'s time zone.
    init(_ date: Date, calendar: Calendar) {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 2000, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    /// From the stored form, `yyyymmdd`.
    init(key: Int) {
        self.init(year: key / 10_000, month: key / 100 % 100, day: key % 100)
    }

    /// The stored form, `yyyymmdd`: sorts like the days it stands for.
    var key: Int { year * 10_000 + month * 100 + day }

    static func < (lhs: Day, rhs: Day) -> Bool { lhs.key < rhs.key }

    /// Midnight at the start of the day, in `calendar`'s time zone.
    func start(in calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    /// The moment `minutes` after midnight on this day, in `calendar`'s time zone.
    func date(atMinutes minutes: Int, in calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: minutes / 60, minute: minutes % 60))
            ?? start(in: calendar)
    }

    func adding(days: Int, in calendar: Calendar) -> Day {
        Day(calendar.date(byAdding: .day, value: days, to: start(in: calendar)) ?? start(in: calendar), calendar: calendar)
    }

    /// Whole days from `self` to `other`: positive when `other` is later.
    func days(to other: Day, in calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: start(in: calendar), to: other.start(in: calendar)).day ?? 0
    }

    /// The seven days of the week this day is in, from the calendar's first weekday.
    func week(in calendar: Calendar) -> [Day] {
        let offset = (weekday(in: calendar) - calendar.firstWeekday + 7) % 7
        let first = adding(days: -offset, in: calendar)
        return (0..<7).map { first.adding(days: $0, in: calendar) }
    }

    /// 1 is Sunday, as in `Calendar`.
    func weekday(in calendar: Calendar) -> Int {
        calendar.component(.weekday, from: start(in: calendar))
    }
}
