/// The Serie of a habit and the Serie piena of all of them, counted in logical days.
///
/// Today not done yet never breaks a streak: the day is not over. Days with nothing expected
/// are neutral: they neither break a streak nor add to it. Weekly habits count in weeks and
/// stay out of the Serie piena, which counts days.
nonisolated enum Streak {
    private enum Day {
        case done, neutral, missed
    }

    /// Expected days in a row, up to today, on which `habit` was done; for a weekly habit, weeks
    /// in a row with the goal reached, where the current week never breaks it.
    static func current(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        if case .timesPerWeek = habit.schedule {
            return weeks(of: habit, today: today, firstWeekday: firstWeekday)
        }
        return countBack(from: today, to: habit.createdOn) { day in
            if habit.schedule.includes(day) == false { return .neutral }
            return habit.isDone(on: day) ? .done : .missed
        }
    }

    /// Days in a row, up to today, on which every habit expected that day was done.
    static func full(of habits: [Habit], today: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        return countBack(from: today, to: firstDay) { day in
            let expected = habits.filter { $0.createdOn <= day && $0.schedule.includes(day) }
            if expected.isEmpty { return .neutral }
            return expected.allSatisfy { $0.isDone(on: day) } ? .done : .missed
        }
    }

    private static func weeks(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        let isReached = { (lastDay: LogicalDay) in
            HabitProgress(of: habit, today: lastDay, firstWeekday: firstWeekday).isComplete
        }
        let thisWeek = today.weekStart(firstWeekday: firstWeekday)
        var weekEnd = isReached(today) ? thisWeek + 6 : thisWeek - 1
        var count = 0
        while weekEnd >= habit.createdOn, isReached(weekEnd) {
            count += 1
            weekEnd = weekEnd - 7
        }
        return count
    }

    private static func countBack(from today: LogicalDay, to firstDay: LogicalDay, result: (LogicalDay) -> Day) -> Int {
        var day = result(today) == .done ? today : today - 1
        var count = 0
        while day >= firstDay {
            switch result(day) {
            case .done: count += 1
            case .neutral: break
            case .missed: return count
            }
            day = day - 1
        }
        return count
    }
}
