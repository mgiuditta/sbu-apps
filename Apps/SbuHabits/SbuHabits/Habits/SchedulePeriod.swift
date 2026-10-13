/// The span a counted schedule sets its goal over: a week, or a calendar month.
nonisolated enum SchedulePeriod: Hashable, Sendable {
    case week
    case month

    /// The first day of the period `day` falls in. Weeks start on `firstWeekday`; months on the
    /// 1st, whatever the first weekday.
    func start(of day: LogicalDay, firstWeekday: Int) -> LogicalDay {
        switch self {
        case .week: day.weekStart(firstWeekday: firstWeekday)
        case .month: day.monthStart
        }
    }

    /// The last day of the period `day` falls in.
    func end(of day: LogicalDay, firstWeekday: Int) -> LogicalDay {
        let start = start(of: day, firstWeekday: firstWeekday)
        switch self {
        case .week: return start + 6
        case .month: return start + start.daysInMonth - 1
        }
    }
}
