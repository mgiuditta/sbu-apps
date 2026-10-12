/// The Serie of a habit and the Serie piena of all of them, counted in logical days.
///
/// Today not done yet never breaks a streak: the day is not over. Days with nothing expected
/// and skipped days are neutral: they neither break a streak nor add to it. An Abitudine da
/// evitare counts a day once it is over and was within its Limite; going over it breaks a
/// streak at once, today too. Weekly habits count in weeks and stay out of the Serie piena,
/// which counts days.
nonisolated enum Streak {
    private enum Day {
        case done, neutral, missed
        /// Today, not done yet: neutral alone, but it keeps the Serie piena from counting today.
        case pending
    }

    /// Expected days in a row, up to today, on which `habit` was done; for a weekly habit, weeks
    /// in a row with the goal reached, where the current week never breaks it.
    static func current(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        if case .timesPerWeek = habit.schedule {
            return weeks(of: habit, today: today, firstWeekday: firstWeekday)
        }
        return countBack(from: today, to: habit.createdOn) { verdict(of: habit, on: $0, today: today) }
    }

    /// Days in a row, up to today, on which every habit expected that day was done.
    static func full(of habits: [Habit], today: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        return countBack(from: today, to: firstDay) { day in
            let verdicts = habits.filter { $0.createdOn <= day }.map { verdict(of: $0, on: day, today: today) }
            for result in [Day.missed, .pending, .done] where verdicts.contains(result) {
                return result
            }
            return .neutral
        }
    }

    /// The longest Serie the habit ever had, in days or, for a weekly habit, in weeks.
    static func best(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        var best = 0
        var run = 0
        if case .timesPerWeek = habit.schedule {
            let thisWeek = today.weekStart(firstWeekday: firstWeekday)
            var weekStart = habit.createdOn.weekStart(firstWeekday: firstWeekday)
            while weekStart <= thisWeek {
                let lastDay = weekStart == thisWeek ? today : weekStart + 6
                switch week(of: habit, endingOn: lastDay, firstWeekday: firstWeekday) {
                case .done: run += 1
                case .neutral, .pending: break
                case .missed where weekStart != thisWeek: run = 0
                case .missed: break
                }
                best = max(best, run)
                weekStart = weekStart + 7
            }
            return best
        }
        var day = habit.createdOn
        while day <= today {
            switch verdict(of: habit, on: day, today: today) {
            case .done: run += 1
            case .missed: run = 0
            case .neutral, .pending: break
            }
            best = max(best, run)
            day = day + 1
        }
        return best
    }

    private static func weeks(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        let thisWeek = today.weekStart(firstWeekday: firstWeekday)
        var weekEnd = week(of: habit, endingOn: today, firstWeekday: firstWeekday) == .done ? thisWeek + 6 : thisWeek - 1
        var count = 0
        while weekEnd >= habit.createdOn {
            switch week(of: habit, endingOn: weekEnd, firstWeekday: firstWeekday) {
            case .done: count += 1
            case .neutral, .pending: break
            case .missed: return count
            }
            weekEnd = weekEnd - 7
        }
        return count
    }

    /// A week whose every day was skipped asked for nothing: neutral, never counted.
    private static func week(of habit: Habit, endingOn lastDay: LogicalDay, firstWeekday: Int) -> Day {
        let progress = HabitProgress(of: habit, today: lastDay, firstWeekday: firstWeekday)
        if progress.goal == 0 { return .neutral }
        return progress.isComplete ? .done : .missed
    }

    /// How a day of a daily habit counts.
    private static func verdict(of habit: Habit, on day: LogicalDay, today: LogicalDay) -> Day {
        if habit.schedule(on: day).includes(day) == false || habit.isSkipped(on: day) { return .neutral }
        if habit.isOverLimit(on: day) { return .missed }
        if day == today {
            // Within the Limite today is not over yet: it adds nothing, but it breaks nothing.
            if habit.limit(on: day) != nil { return .neutral }
            return habit.isDone(on: day) ? .done : .pending
        }
        return habit.isDone(on: day) ? .done : .missed
    }

    private static func countBack(from today: LogicalDay, to firstDay: LogicalDay, result: (LogicalDay) -> Day) -> Int {
        var day = today
        var count = 0
        while day >= firstDay {
            switch result(day) {
            case .done: count += 1
            case .neutral, .pending: break
            case .missed: return count
            }
            day = day - 1
        }
        return count
    }
}
