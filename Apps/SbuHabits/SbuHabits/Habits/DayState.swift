/// What a past day looks like in a habit's history.
nonisolated enum DayState: Equatable, Sendable {
    case done
    case skipped
    /// Expected and not done.
    case missed
    /// Not expected, before the habit existed, today not done yet, or still to come.
    case empty

    init(of habit: Habit, on day: LogicalDay, today: LogicalDay) {
        if day > today || day < habit.createdOn {
            self = .empty
        } else if habit.isDone(on: day) {
            self = .done
        } else if habit.isSkipped(on: day) {
            self = .skipped
        } else if day == today || habit.schedule(on: day).includes(day) == false {
            // A weekly habit has no fixed days, so a day without it is not a miss.
            self = .empty
        } else {
            self = .missed
        }
    }
}
