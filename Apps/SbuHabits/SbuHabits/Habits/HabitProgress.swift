/// How far a habit is toward its goal: today's times, or the week's days for a weekly habit.
nonisolated struct HabitProgress: Equatable, Sendable {
    let done: Int
    let goal: Int
    /// Times marked today, which Annulla ultima can take back.
    let marksToday: Int
    /// Whether a hold takes a mark back instead of adding one.
    let holdUndoes: Bool

    var isComplete: Bool { done >= goal }

    init(of habit: Habit, today: LogicalDay, firstWeekday: Int) {
        marksToday = habit.count(on: today)
        if case .timesPerWeek(let times) = habit.schedule {
            let start = today.weekStart(firstWeekday: firstWeekday)
            done = (0...(today.ordinal - start.ordinal)).count(where: { habit.isDone(on: start + $0) })
            goal = times
            holdUndoes = habit.isDone(on: today)
        } else {
            done = habit.count(on: today)
            goal = habit.timesPerDay
            holdUndoes = habit.isDone(on: today)
        }
    }
}
