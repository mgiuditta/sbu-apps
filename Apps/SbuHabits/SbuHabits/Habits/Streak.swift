/// The Serie of a habit and the Serie piena of all of them, counted in logical days.
///
/// Today not done yet never breaks a streak: the day is not over. Days with nothing expected
/// and skipped days are neutral: they neither break a streak nor add to it. An Abitudine da
/// evitare counts a day once it is over and was within its Limite; going over it breaks a
/// streak at once, today too. Weekly habits count in weeks, monthly ones in calendar months,
/// and both stay out of the Serie piena, which counts days. An Attività di un giorno is expected
/// on its day only: neutral on every other.
nonisolated enum Streak {
    private enum Day {
        case done, neutral, missed
        /// Today, not done yet: neutral alone, but it keeps the Serie piena from counting today.
        case pending
    }

    /// Expected days in a row, up to today, on which `habit` was done; for a weekly or monthly
    /// habit, weeks or months in a row with the goal reached, where the current one never breaks it.
    static func current(of habit: Habit, today: LogicalDay, firstWeekday: Int) -> Int {
        if let period = habit.schedule.period {
            return periods(of: habit, period: period, today: today, firstWeekday: firstWeekday)
        }
        return countBack(from: today, to: habit.createdOn) { verdict(of: habit, on: $0, today: today) }
    }

    /// Days in a row, up to today, on which every habit expected that day was done.
    static func full(of habits: [Habit], today: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        return countBack(from: today, to: firstDay) { fullVerdict(of: habits, on: $0, today: today) }
    }

    /// The longest Serie piena from `first` on: days in a row, up to today, on which every habit
    /// expected that day was done. Days before `first` never count, so a run that started before
    /// it counts from `first`.
    static func bestFull(of habits: [Habit], today: LogicalDay, from first: LogicalDay) -> Int {
        guard let firstDay = habits.map(\.createdOn).min() else { return 0 }
        var best = 0
        var run = 0
        var day = max(first, firstDay)
        while day <= today {
            switch fullVerdict(of: habits, on: day, today: today) {
            case .done: run += 1
            case .missed: run = 0
            case .neutral, .pending: break
            }
            best = max(best, run)
            day = day + 1
        }
        return best
    }

    /// The longest Serie the habit ever had, in days or, for a weekly or monthly habit, in weeks
    /// or months.
    /// - Parameter first: The first day that counts, for the best Serie of a period: a day before
    ///   it never counts, nor a week or month that ended before it. `nil` counts from the start.
    static func best(of habit: Habit, today: LogicalDay, firstWeekday: Int, from first: LogicalDay? = nil) -> Int {
        var best = 0
        var run = 0
        let first = max(first ?? habit.createdOn, habit.createdOn)
        if let period = habit.schedule.period {
            let thisStart = period.start(of: today, firstWeekday: firstWeekday)
            var start = period.start(of: first, firstWeekday: firstWeekday)
            while start <= thisStart {
                let lastDay = start == thisStart ? today : period.end(of: start, firstWeekday: firstWeekday)
                switch result(of: habit, period: period, endingOn: lastDay, firstWeekday: firstWeekday) {
                case .done: run += 1
                case .neutral, .pending: break
                case .missed where start != thisStart: run = 0
                case .missed: break
                }
                best = max(best, run)
                start = lastDay + 1
            }
            return best
        }
        var day = first
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

    /// Weeks or months in a row with the goal reached: the current one counts once reached, and
    /// never breaks the Serie before then.
    private static func periods(of habit: Habit, period: SchedulePeriod, today: LogicalDay, firstWeekday: Int) -> Int {
        let thisStart = period.start(of: today, firstWeekday: firstWeekday)
        var lastDay = result(of: habit, period: period, endingOn: today, firstWeekday: firstWeekday) == .done ? today : thisStart - 1
        var count = 0
        while lastDay >= habit.createdOn {
            switch result(of: habit, period: period, endingOn: lastDay, firstWeekday: firstWeekday) {
            case .done: count += 1
            case .neutral, .pending: break
            case .missed: return count
            }
            lastDay = period.start(of: lastDay, firstWeekday: firstWeekday) - 1
        }
        return count
    }

    /// How a week or month counts, judged on its days up to `lastDay`. One whose every day was
    /// skipped asked for nothing: neutral, never counted.
    private static func result(of habit: Habit, period: SchedulePeriod, endingOn lastDay: LogicalDay, firstWeekday: Int) -> Day {
        let progress = HabitProgress(of: habit, today: lastDay, firstWeekday: firstWeekday)
        if progress.goal == 0 { return .neutral }
        return progress.isComplete ? .done : .missed
    }

    /// How a day counts for the Serie piena: missed if any habit expected that day was missed.
    private static func fullVerdict(of habits: [Habit], on day: LogicalDay, today: LogicalDay) -> Day {
        let verdicts = habits.filter { $0.createdOn <= day }.map { verdict(of: $0, on: day, today: today) }
        for result in [Day.missed, .pending, .done] where verdicts.contains(result) {
            return result
        }
        return .neutral
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
