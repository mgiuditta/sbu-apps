import Foundation

/// A day as the user lives it: it starts at `startHour`, not always at midnight.
///
/// Stored as the number of days since 1 January 1970, so the day before is `self - 1`.
/// Everything except this initializer works on logical days, never on raw `Date`s.
nonisolated struct LogicalDay: Hashable, Comparable, Codable, CodingKeyRepresentable, Identifiable, Sendable {
    let ordinal: Int

    var id: Int { ordinal }

    init(ordinal: Int) {
        self.ordinal = ordinal
    }

    /// The logical day `date` belongs to.
    /// - Parameters:
    ///   - date: The moment to place.
    ///   - startHour: Hour the day starts, from 0 to 6: with 4, 02:00 belongs to the day before.
    ///   - calendar: Supplies the time zone; days are always counted on the Gregorian calendar.
    init(_ date: Date, startHour: Int = 0, calendar: Calendar = .current) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day, .hour], from: date)

        // UTC has no daylight saving time, so its midnights are exactly 86 400 s apart.
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        let midnight = utc.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day)) ?? date
        let calendarDay = Int((midnight.timeIntervalSince1970 / 86_400).rounded(.down))

        ordinal = (parts.hour ?? 0) < startHour ? calendarDay - 1 : calendarDay
    }

    /// Gregorian weekday, 1 for Sunday through 7 for Saturday; day 0, 1 January 1970, was a Thursday.
    var weekday: Int {
        ((ordinal + 4) % 7 + 7) % 7 + 1
    }

    /// The first day of the week this day falls in, for a week starting on `firstWeekday`.
    func weekStart(firstWeekday: Int) -> LogicalDay {
        self - (weekday - firstWeekday + 7) % 7
    }

    /// The first day of the calendar month this day falls in, on the Gregorian calendar.
    var monthStart: LogicalDay {
        self - (Self.utc.component(.day, from: utcMidnight) - 1)
    }

    /// How many days the calendar month this day falls in has: 28 to 31.
    var daysInMonth: Int {
        Self.utc.range(of: .day, in: .month, for: utcMidnight)?.count ?? 30
    }

    /// The Gregorian calendar in UTC, where day `ordinal` starts exactly `ordinal` days after 1970.
    private static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private var utcMidnight: Date {
        Date(timeIntervalSince1970: Double(ordinal) * 86_400)
    }

    /// Noon of this day in `calendar`'s time zone: a moment safely inside the day, to format its
    /// date or to set a time on it.
    func noon(in calendar: Calendar) -> Date {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        var parts = utc.dateComponents([.year, .month, .day], from: Date(timeIntervalSince1970: Double(ordinal) * 86_400))
        parts.hour = 12
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        return gregorian.date(from: parts) ?? .now
    }

    /// From `startHour` on this day to `startHour` on the next, in `calendar`'s time zone: the
    /// moments whose data counts for this day.
    func interval(startHour: Int, in calendar: Calendar) -> DateInterval {
        func start(of day: LogicalDay) -> Date {
            let noon = day.noon(in: calendar)
            return calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: noon) ?? noon
        }
        return DateInterval(start: start(of: self), end: start(of: self + 1))
    }

    static func < (lhs: LogicalDay, rhs: LogicalDay) -> Bool {
        lhs.ordinal < rhs.ordinal
    }

    static func - (day: LogicalDay, days: Int) -> LogicalDay {
        LogicalDay(ordinal: day.ordinal - days)
    }

    static func + (day: LogicalDay, days: Int) -> LogicalDay {
        LogicalDay(ordinal: day.ordinal + days)
    }

    // A single value in JSON, and a plain key when it indexes a dictionary.
    init(from decoder: any Decoder) throws {
        ordinal = try decoder.singleValueContainer().decode(Int.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(ordinal)
    }

    var codingKey: any CodingKey {
        ordinal.codingKey
    }

    init?<Key: CodingKey>(codingKey: Key) {
        guard let ordinal = Int(codingKey: codingKey) else { return nil }
        self.ordinal = ordinal
    }
}
