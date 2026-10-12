import Foundation

/// A day as the user lives it: it starts at `startHour`, not always at midnight.
///
/// Stored as the number of days since 1 January 1970, so the day before is `self - 1`.
/// Everything except this initializer works on logical days, never on raw `Date`s.
nonisolated struct LogicalDay: Hashable, Comparable, Codable, CodingKeyRepresentable, Sendable {
    let ordinal: Int

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

    static func < (lhs: LogicalDay, rhs: LogicalDay) -> Bool {
        lhs.ordinal < rhs.ordinal
    }

    static func - (day: LogicalDay, days: Int) -> LogicalDay {
        LogicalDay(ordinal: day.ordinal - days)
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
