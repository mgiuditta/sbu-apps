/// The habits the grid shows today: only those expected today.
nonisolated enum TodayGrid {
    static func habits(_ habits: [Habit], on today: LogicalDay) -> [Habit] {
        habits.filter { $0.schedule.includes(today) }
    }
}
