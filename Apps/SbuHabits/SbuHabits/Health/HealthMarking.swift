/// Which habits Salute marks done: a habit to do, linked, expected on the day, not skipped and
/// not done yet, whose measure reached the goal. Salute only adds: it fills the day to its goal
/// and never takes a mark back, so marks by hand still count.
nonisolated enum HealthMarking {
    /// Marks the habits whose measure reached the goal on `day`.
    /// - Parameter totals: Each linked measure's total on `day`; a measure missing is left alone.
    /// - Returns: Whether any habit changed.
    static func mark(_ habits: inout [Habit], totals: [HealthMeasure: Double], on day: LogicalDay) -> Bool {
        var changed = false
        for index in habits.indices {
            let habit = habits[index]
            guard let link = habit.health, let total = totals[link.measure], link.isReached(by: total),
                  isOpen(habit, on: day) else { continue }
            habits[index].log[day] = habit.timesPerDay(on: day)
            changed = true
        }
        return changed
    }

    private static func isOpen(_ habit: Habit, on day: LogicalDay) -> Bool {
        let schedule = habit.schedule(on: day)
        return habit.limit(on: day) == nil
            && day >= habit.createdOn
            && (schedule.isWeekly || schedule.includes(day))
            && habit.isSkipped(on: day) == false
            && habit.isDone(on: day) == false
    }
}
