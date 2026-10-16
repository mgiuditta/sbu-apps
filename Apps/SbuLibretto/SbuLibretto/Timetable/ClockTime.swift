import Foundation

/// A time of day as minutes from midnight, always written in 24 hours: "09:00", "14:30".
///
/// The original's reviews report lessons moved by twelve hours (AM/PM): here the time is stored as
/// minutes, never as a date in a time zone, and written without AM or PM in every language.
nonisolated struct ClockTime: Hashable, Comparable, Sendable {
    static let minutesInDay = 24 * 60

    /// 0 to 1439.
    let minutes: Int

    /// Any number of minutes, folded into one day: 1440 is midnight, -30 is 23:30.
    init(minutes: Int) {
        let folded = minutes % Self.minutesInDay
        self.minutes = folded < 0 ? folded + Self.minutesInDay : folded
    }

    init(hour: Int, minute: Int) {
        self.init(minutes: hour * 60 + minute)
    }

    /// The hour and minute of a date on the given calendar, as the time picker sets them.
    init(_ date: Date, calendar: Calendar) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }

    var hour: Int { minutes / 60 }
    var minute: Int { minutes % 60 }

    /// "09:05", 24 hours, two digits each.
    var text: String {
        Duration.seconds(minutes * 60).formatted(.time(pattern: .hourMinute(padHourToLength: 2)))
    }

    /// This time on the day of `date`, for the time picker.
    func date(on date: Date, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }

    static func < (lhs: ClockTime, rhs: ClockTime) -> Bool {
        lhs.minutes < rhs.minutes
    }
}
