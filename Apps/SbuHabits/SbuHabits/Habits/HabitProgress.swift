/// How far a habit is toward its goal: today's times, or the week's days for a weekly habit;
/// for an Abitudine da evitare, today's times given in against the Limite.
nonisolated struct HabitProgress: Equatable, Sendable {
    let done: Int
    /// Zero when every day of a weekly habit's week was skipped: nothing was asked that week.
    let goal: Int
    /// Times marked today, which Annulla ultima can take back.
    let marksToday: Int
    /// Whether a hold takes a mark back instead of adding one.
    let holdUndoes: Bool
    let isSkippedToday: Bool
    /// The Limite of an Abitudine da evitare, `nil` for a habit to do; `goal` holds it too.
    let limit: Int?

    /// Done, or for an Abitudine da evitare, still within the Limite.
    var isComplete: Bool { limit == nil ? done >= goal : done <= goal }

    var isOverLimit: Bool { limit != nil && done > goal }

    /// Times still allowed today before going over the Limite.
    var margin: Int { max(goal - done, 0) }

    init(of habit: Habit, today: LogicalDay, firstWeekday: Int) {
        marksToday = habit.count(on: today)
        isSkippedToday = habit.isSkipped(on: today)
        limit = habit.limit(on: today)
        // Every hold of an Abitudine da evitare is one more time given in.
        holdUndoes = limit == nil && habit.isDone(on: today)
        if case .timesPerWeek(let times) = habit.schedule(on: today) {
            let start = today.weekStart(firstWeekday: firstWeekday)
            let days = (0...(today.ordinal - start.ordinal)).map { start + $0 }
            done = days.count { habit.isDone(on: $0) }
            // Each skipped day lowers the week's goal by one.
            goal = max(times - days.count { habit.isSkipped(on: $0) }, 0)
        } else {
            done = habit.count(on: today)
            goal = limit ?? habit.timesPerDay(on: today)
        }
    }
}
