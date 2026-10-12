/// The Serie of a habit and the Serie piena of all of them, counted in logical days.
///
/// Today not done yet never breaks a streak: the day is not over.
nonisolated enum Streak {
    /// Days in a row, up to today, on which `habit` was done.
    static func current(of habit: Habit, today: LogicalDay) -> Int {
        countBack(from: today, to: habit.createdOn) { habit.isDone(on: $0) }
    }

    /// Days in a row, up to today, on which every habit that existed that day was done.
    static func full(of habits: [Habit], today: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        return countBack(from: today, to: firstDay) { day in
            habits.allSatisfy { $0.createdOn > day || $0.isDone(on: day) }
        }
    }

    private static func countBack(from today: LogicalDay, to firstDay: LogicalDay, isComplete: (LogicalDay) -> Bool) -> Int {
        var day = isComplete(today) ? today : today - 1
        var count = 0
        while day >= firstDay, isComplete(day) {
            count += 1
            day = day - 1
        }
        return count
    }
}
