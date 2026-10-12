/// Which days a habit is expected.
nonisolated enum Schedule: Hashable, Codable, Sendable {
    /// Times per week the form offers: seven would be every day.
    static let timesPerWeekRange = 1...6

    case everyDay
    /// Gregorian weekday numbers, 1 for Sunday through 7 for Saturday, as `Calendar` counts them.
    case weekdays(Set<Int>)
    /// On any days of the week, this many of them; counted in weeks, never in days.
    case timesPerWeek(Int)

    var isWeekly: Bool {
        if case .timesPerWeek = self { true } else { false }
    }

    /// Whether `day` is one of the habit's fixed days. A weekly habit has no fixed days.
    func includes(_ day: LogicalDay) -> Bool {
        switch self {
        case .everyDay: true
        case .weekdays(let weekdays): weekdays.contains(day.weekday)
        case .timesPerWeek: false
        }
    }
}
