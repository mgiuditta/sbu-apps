/// The numbers of one page of the Statistiche over a period: every habit, or one.
///
/// - Completion rate: done over done and missed, as `DayState` judges each day. Skipped days and
///   days with nothing expected stay out, a day done when it was not expected too. An Abitudine
///   da evitare is done on a day over within its Limite and missed once over it; today within the
///   Limite is not over yet and stays out. A weekly or monthly habit counts its goal, not its
///   days: a week of 3 times asks for 3, done up to 3, and the rest missed once the week is over;
///   it is counted on its last day, so a week belongs to the period it ends in, and the current
///   one counts only what is done. A week whose every day was skipped asked for nothing.
/// - Completions: the marks of habits to do, each time of a habit done several times a day
///   included; for an Abitudine da evitare, whose marks are times given in, the days done.
/// - Serie migliore: the longest Serie inside the period, so it follows the button like the
///   rate; Dall'inizio is the best ever. The page of every habit takes the Serie piena.
/// - The line: the rate over about `linePoints` stretches of days in a row, the last one ending
///   today; a stretch with nothing expected has no point.
/// - The hours: the marks of habits to do, by hour on the clock, as `CompletionHours` counts them;
///   days marked before hours were saved stay out.
nonisolated struct HabitStatistics: Equatable, Sendable {
    /// About how many points the completion line has, whatever the period.
    static let linePoints = 30

    let firstDay: LogicalDay
    let today: LogicalDay
    let tally: CompletionTally
    let completions: Int
    let bestStreak: Int
    let line: [CompletionPoint]
    /// Seven counts, starting from the first day of the user's week.
    let weekdays: [WeekdayCount]
    /// 24 counts, index 0 for 00:00–00:59.
    let hours: [Int]

    /// Days counted, today included.
    var dayCount: Int { today.ordinal - firstDay.ordinal + 1 }

    /// Some mark in the period has its hour.
    var hasHours: Bool { hours.contains { $0 > 0 } }

    /// The page of every habit: its Serie migliore is the Serie piena.
    static func all(_ habits: [Habit], period: StatisticsPeriod, today: LogicalDay, firstWeekday: Int) -> HabitStatistics {
        let firstDay = period.firstDay(today: today, start: habits.map(\.createdOn).min() ?? today)
        return HabitStatistics(habits: habits, firstDay: firstDay, today: today, firstWeekday: firstWeekday) {
            Streak.bestFull(of: habits, today: today, from: firstDay)
        }
    }

    /// The page of one habit: its Serie migliore in its own unit, days, weeks or months.
    static func habit(_ habit: Habit, period: StatisticsPeriod, today: LogicalDay, firstWeekday: Int) -> HabitStatistics {
        let firstDay = period.firstDay(today: today, start: habit.createdOn)
        return HabitStatistics(habits: [habit], firstDay: firstDay, today: today, firstWeekday: firstWeekday) {
            Streak.best(of: habit, today: today, firstWeekday: firstWeekday, from: firstDay)
        }
    }

    private init(habits: [Habit], firstDay: LogicalDay, today: LogicalDay, firstWeekday: Int, bestStreak: () -> Int) {
        self.firstDay = firstDay
        self.today = today
        // One walk through the days: each day's tally and completions feed every number.
        var days: [CompletionTally] = []
        var completions = 0
        var perWeekday = Array(repeating: 0, count: 8)
        var day = firstDay
        while day <= today {
            var dayTally = CompletionTally.zero
            var dayCompletions = 0
            for habit in habits {
                dayTally += Self.tally(of: habit, on: day, today: today, firstWeekday: firstWeekday)
                dayCompletions += Self.completions(of: habit, on: day, today: today)
            }
            days.append(dayTally)
            completions += dayCompletions
            perWeekday[day.weekday] += dayCompletions
            day = day + 1
        }
        tally = days.reduce(.zero, +)
        self.completions = completions
        self.bestStreak = bestStreak()
        line = Self.line(of: days, from: firstDay)
        weekdays = (0..<7).map { offset in
            let weekday = (firstWeekday - 1 + offset) % 7 + 1
            return WeekdayCount(weekday: weekday, count: perWeekday[weekday])
        }
        // An Abitudine da evitare's marks are times given in, not completions.
        hours = CompletionHours.counts(of: habits.filter { $0.limit == nil }, in: firstDay...max(firstDay, today))
    }

    /// What `day` adds to the completion rate of `habit`.
    static func tally(of habit: Habit, on day: LogicalDay, today: LogicalDay, firstWeekday: Int) -> CompletionTally {
        guard day >= habit.createdOn, day <= today else { return .zero }
        let schedule = habit.schedule(on: day)
        if let period = schedule.period {
            // Judged once, on the period's last day, or today for the current one.
            guard day == today || day == period.end(of: day, firstWeekday: firstWeekday) else { return .zero }
            let progress = HabitProgress(of: habit, today: day, firstWeekday: firstWeekday)
            let done = min(progress.done, progress.goal)
            return CompletionTally(done: done, missed: day == today ? 0 : progress.goal - done)
        }
        // A day done that was not expected is a bonus, not part of the rate.
        guard schedule.includes(day) else { return .zero }
        switch DayState(of: habit, on: day, today: today) {
        case .done: return CompletionTally(done: 1, missed: 0)
        case .missed: return CompletionTally(done: 0, missed: 1)
        case .skipped, .empty: return .zero
        }
    }

    /// The completions of `habit` on `day`: its marks, or for an Abitudine da evitare, one for a
    /// day done.
    static func completions(of habit: Habit, on day: LogicalDay, today: LogicalDay) -> Int {
        guard day >= habit.createdOn, day <= today else { return 0 }
        if habit.limit(on: day) != nil {
            return DayState(of: habit, on: day, today: today) == .done ? 1 : 0
        }
        return habit.count(on: day)
    }

    /// The days' tallies in stretches of the same length, the last one ending on the last day,
    /// so there are at most about `linePoints` of them.
    static func line(of days: [CompletionTally], from firstDay: LogicalDay) -> [CompletionPoint] {
        guard days.isEmpty == false else { return [] }
        let size = (days.count + linePoints - 1) / linePoints
        var stretches: [(first: Int, last: Int)] = []
        var last = days.count - 1
        while last >= 0 {
            stretches.append((first: max(last - size + 1, 0), last: last))
            last -= size
        }
        return stretches.reversed().enumerated().compactMap { index, stretch in
            let tally = days[stretch.first...stretch.last].reduce(.zero, +)
            return tally.rate.map { CompletionPoint(index: index, firstDay: firstDay + stretch.first, lastDay: firstDay + stretch.last, rate: $0) }
        }
    }
}
