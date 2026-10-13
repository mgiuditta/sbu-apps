/// Which days a habit is expected.
nonisolated enum Schedule: Hashable, Codable, Sendable {
    /// Times per week the form offers: seven would be every day.
    static let timesPerWeekRange = 1...6
    /// Times per month the form offers: 28 would be every day of February.
    static let timesPerMonthRange = 1...27

    case everyDay
    /// Gregorian weekday numbers, 1 for Sunday through 7 for Saturday, as `Calendar` counts them.
    case weekdays(Set<Int>)
    /// On any days of the week, this many of them; counted in weeks, never in days.
    case timesPerWeek(Int)
    /// On any days of the calendar month, this many of them; counted in months, never in days.
    case timesPerMonth(Int)
    /// Only on this one day: an Attività di un giorno.
    case oneDay(LogicalDay)

    /// The period a counted schedule sets its goal over, `nil` for a schedule with fixed days.
    var period: SchedulePeriod? {
        switch self {
        case .timesPerWeek: .week
        case .timesPerMonth: .month
        case .everyDay, .weekdays, .oneDay: nil
        }
    }

    /// The days a counted schedule asks for in each period, `nil` for a schedule with fixed days.
    var timesPerPeriod: Int? {
        switch self {
        case .timesPerWeek(let times), .timesPerMonth(let times): times
        case .everyDay, .weekdays, .oneDay: nil
        }
    }

    /// Counted in weeks or months, with no fixed days.
    var isCounted: Bool {
        period != nil
    }

    /// An Attività di un giorno.
    var isOneDay: Bool {
        if case .oneDay = self { true } else { false }
    }

    /// Whether `day` is one of the habit's fixed days. A counted habit has no fixed days.
    func includes(_ day: LogicalDay) -> Bool {
        switch self {
        case .everyDay: true
        case .weekdays(let weekdays): weekdays.contains(day.weekday)
        case .timesPerWeek, .timesPerMonth: false
        case .oneDay(let only): day == only
        }
    }
}
