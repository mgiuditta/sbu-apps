/// The numbers of the Statistiche pages already worked out, so a page swiped back to, or drawn
/// again, does not walk the history again. Everything is worked out again once the habits,
/// today or the first day of the week change.
final class StatisticsCache {
    private struct Key: Hashable {
        /// `nil` for the page of every habit.
        let habitID: Habit.ID?
        let period: StatisticsPeriod
    }

    private var habits: [Habit] = []
    private var today: LogicalDay?
    private var firstWeekday = 0
    private var pages: [Key: HabitStatistics] = [:]

    /// The numbers of the page of `habit`, or of every habit when it is `nil`.
    func statistics(of habit: Habit?, in habits: [Habit], period: StatisticsPeriod, today: LogicalDay, firstWeekday: Int) -> HabitStatistics {
        // Arrays compare their storage first: the same habits cost nothing to compare.
        if habits != self.habits || today != self.today || firstWeekday != self.firstWeekday {
            self.habits = habits
            self.today = today
            self.firstWeekday = firstWeekday
            pages = [:]
        }
        let key = Key(habitID: habit?.id, period: period)
        if let cached = pages[key] {
            return cached
        }
        let statistics = if let habit {
            HabitStatistics.habit(habit, period: period, today: today, firstWeekday: firstWeekday)
        } else {
            HabitStatistics.all(habits, period: period, today: today, firstWeekday: firstWeekday)
        }
        pages[key] = statistics
        return statistics
    }
}
