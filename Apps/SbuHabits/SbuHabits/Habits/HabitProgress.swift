/// How far a habit is toward its goal: today's times, or the week's days for a weekly habit.
nonisolated struct HabitProgress: Equatable, Sendable {
    let done: Int
    let goal: Int
    /// Times marked today, which Annulla ultima can take back.
    let marksToday: Int
    /// Whether a hold takes a mark back instead of adding one.
    let holdUndoes: Bool
    let isSkippedToday: Bool

    var isComplete: Bool { done >= goal }

    init(of habit: Habit, today: LogicalDay, firstWeekday: Int) {
        marksToday = habit.count(on: today)
        isSkippedToday = habit.isSkipped(on: today)
        if case .timesPerWeek(let times) = habit.schedule {
            let start = today.weekStart(firstWeekday: firstWeekday)
            let days = (0...(today.ordinal - start.ordinal)).map { start + $0 }
            done = days.count { habit.isDone(on: $0) }
            // Each skipped day lowers the week's goal by one.
            goal = max(times - days.count { habit.isSkipped(on: $0) }, 0)
            holdUndoes = habit.isDone(on: today)
        } else {
            done = habit.count(on: today)
            goal = habit.timesPerDay
            holdUndoes = habit.isDone(on: today)
        }
    }
}
