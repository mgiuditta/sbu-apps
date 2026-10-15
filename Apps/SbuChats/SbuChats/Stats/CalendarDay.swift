import Foundation

/// The local calendar fields of a moment, read once per quarter hour of the chat.
///
/// Every time zone and daylight saving change falls on a quarter hour, so moments in the same
/// quarter hour share day, hour and weekday. A chat of 40,000 messages asks the calendar a few
/// thousand times instead of 40,000.
nonisolated struct CalendarDay: Equatable, Sendable {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    /// 1 is Sunday, as in `Calendar`.
    let weekday: Int

    /// Days since a fixed origin: consecutive dates differ by one, whatever the month.
    var dayNumber: Int {
        // Julian day number of the Gregorian date (Fliegel and Van Flandern).
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    /// Reads calendar fields with a cache per quarter hour.
    struct Reader {
        let calendar: Calendar
        private var cache: [Int: CalendarDay] = [:]

        init(calendar: Calendar) {
            self.calendar = calendar
        }

        mutating func day(of date: Date) -> CalendarDay {
            let key = Int((date.timeIntervalSince1970 / 900).rounded(.down))
            if let cached = cache[key] { return cached }
            let fields = calendar.dateComponents([.year, .month, .day, .hour, .weekday], from: date)
            let day = CalendarDay(year: fields.year ?? 0, month: fields.month ?? 1, day: fields.day ?? 1,
                                  hour: fields.hour ?? 0, weekday: fields.weekday ?? 1)
            cache[key] = day
            return day
        }
    }
}
