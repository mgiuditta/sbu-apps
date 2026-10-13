/// What a one-habit widget draws, already worked out: the habit chosen in "Modifica widget", or
/// the first still to do today, with its ring and Serie, and only what its insight needs.
nonisolated struct HabitInsightContent: Equatable, Sendable {
    let insight: HabitInsight
    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    /// The habit's Statistiche from its first day; `nil` unless the insight draws them.
    let statistics: HabitStatistics?
    /// The days of this month; empty unless the insight is the calendar.
    let calendar: [CalendarDot]

    /// `nil` when there is no habit to show: none saved, or none expected today and none chosen.
    init?(habits: [Habit], chosen: Habit.ID?, insight: HabitInsight, today: LogicalDay, firstWeekday: Int) {
        guard let habit = WidgetChoice.single(habits, chosen: chosen, today: today, firstWeekday: firstWeekday) else { return nil }
        self.insight = insight
        self.habit = habit
        progress = HabitProgress(of: habit, today: today, firstWeekday: firstWeekday)
        streak = Streak.current(of: habit, today: today, firstWeekday: firstWeekday)
        statistics = insight.needsStatistics ? .habit(habit, period: .all, today: today, firstWeekday: firstWeekday) : nil
        calendar = insight == .calendar ? MonthCalendar.dots(of: habit, today: today) : []
    }
}
