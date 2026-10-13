/// The days of the calendar month today falls in, from the 1st, each with how it looks for a
/// habit: the calendar widget, seven to a row as in Streaks.
nonisolated enum MonthCalendar {
    static func dots(of habit: Habit, today: LogicalDay) -> [CalendarDot] {
        let first = today.monthStart
        return (0..<today.daysInMonth).map { offset in
            let day = first + offset
            return CalendarDot(day: day, state: state(of: habit, on: day, today: today))
        }
    }

    private static func state(of habit: Habit, on day: LogicalDay, today: LogicalDay) -> CalendarDotState {
        switch DayState(of: habit, on: day, today: today) {
        case .done: .done
        case .missed: .missed
        case .skipped: .skipped
        case .empty where day == today && day >= habit.createdOn: .today
        case .empty: .rest
        }
    }
}
