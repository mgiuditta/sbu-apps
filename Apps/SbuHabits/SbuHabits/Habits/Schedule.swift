/// Which days a habit is expected.
nonisolated enum Schedule: Hashable, Codable, Sendable {
    case everyDay
    /// Gregorian weekday numbers, 1 for Sunday through 7 for Saturday, as `Calendar` counts them.
    case weekdays(Set<Int>)

    func includes(_ day: LogicalDay) -> Bool {
        switch self {
        case .everyDay: true
        case .weekdays(let weekdays): weekdays.contains(day.weekday)
        }
    }
}
