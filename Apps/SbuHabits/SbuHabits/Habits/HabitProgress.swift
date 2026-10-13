/// How far a habit is toward its goal: today's times, or the days of the week or month for a
/// weekly or monthly habit;
/// for an Abitudine da evitare, today's times given in against the Limite.
nonisolated struct HabitProgress: Equatable, Sendable {
    let done: Int
    /// Zero when every day of a weekly or monthly habit's period was skipped: nothing was asked.
    let goal: Int
    /// Times marked today, which Annulla l'ultimo segno can take back.
    let marksToday: Int
    /// Whether a hold takes a mark back instead of adding one.
    let holdUndoes: Bool
    let isSkippedToday: Bool
    /// The Limite of an Abitudine da evitare, `nil` for a habit to do; `goal` holds it too.
    let limit: Int?

    /// Done, or for an Abitudine da evitare, still within the Limite.
    var isComplete: Bool { limit == nil ? done >= goal : done <= goal }

    var isOverLimit: Bool { limit != nil && done > goal }

    /// Still asks for something today: a habit to do not yet done. An Abitudine da evitare never
    /// does, within the Limite or over it.
    var isStillToDo: Bool { limit == nil && isComplete == false }

    /// Times still allowed today before going over the Limite.
    var margin: Int { max(goal - done, 0) }

    init(of habit: Habit, today: LogicalDay, firstWeekday: Int) {
        marksToday = habit.count(on: today)
        isSkippedToday = habit.isSkipped(on: today)
        limit = habit.limit(on: today)
        // Every hold of an Abitudine da evitare is one more time given in.
        holdUndoes = limit == nil && habit.isDone(on: today)
        let schedule = habit.schedule(on: today)
        if let period = schedule.period, let times = schedule.timesPerPeriod {
            let start = period.start(of: today, firstWeekday: firstWeekday)
            let days = (0...(today.ordinal - start.ordinal)).map { start + $0 }
            done = days.count { habit.isDone(on: $0) }
            // Each skipped day lowers the period's goal by one.
            goal = max(times - days.count { habit.isSkipped(on: $0) }, 0)
        } else {
            done = habit.count(on: today)
            goal = limit ?? habit.timesPerDay(on: today)
        }
    }
}
