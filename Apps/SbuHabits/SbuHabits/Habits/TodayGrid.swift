/// The habits the grid shows today: those expected today, an Attività di un giorno on its day
/// only, and weekly or monthly ones still short of their goal or marked or skipped today.
nonisolated enum TodayGrid {
    static func habits(_ habits: [Habit], on today: LogicalDay, firstWeekday: Int) -> [Habit] {
        habits.filter { habit in
            guard habit.schedule.isCounted else { return habit.schedule.includes(today) }
            return habit.count(on: today) > 0 || habit.isSkipped(on: today) || HabitProgress(of: habit, today: today, firstWeekday: firstWeekday).isComplete == false
        }
    }
}
