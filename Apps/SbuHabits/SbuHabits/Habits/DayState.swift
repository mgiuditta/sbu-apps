/// What a past day looks like in a habit's history.
nonisolated enum DayState: Equatable, Sendable {
    case done
    case skipped
    /// Expected and not done.
    case missed
    /// Not expected, before the habit existed, today not done yet (or within the Limite), or still to come.
    case empty

    init(of habit: Habit, on day: LogicalDay, today: LogicalDay) {
        if day > today || day < habit.createdOn {
            self = .empty
        } else if habit.isSkipped(on: day) {
            // A skip clears the marks, and a mark takes the skip back: never both.
            self = .skipped
        } else if habit.isOverLimit(on: day) {
            self = .missed
        } else if day == today, habit.limit(on: day) != nil {
            // An Abitudine da evitare within its Limite is done only once the day is over.
            self = .empty
        } else if habit.isDone(on: day) {
            self = .done
        } else if day == today || habit.schedule(on: day).includes(day) == false {
            // A weekly or monthly habit has no fixed days, so a day without it is not a miss.
            self = .empty
        } else {
            self = .missed
        }
    }
}
