/// A habit's checkbox on the tool screen: ticked once today's times are all done. Ticking it
/// marks every time left today; unticking takes the last one back.
///
/// An Abitudine da evitare has no checkbox: nothing gets done, every time is one more given in.
/// A habit done more times a day keeps a small control that adds one time.
nonisolated struct HabitCheck: Equatable, Sendable {
    /// Today's times are all done.
    let isChecked: Bool
    /// A habit to do: an Abitudine da evitare gets no checkbox.
    let hasCheckbox: Bool
    /// More than one time asked today: one time can be added without ticking the box.
    let countsTimes: Bool
    /// Done for today: the box ticked, or a weekly or monthly goal already reached.
    let isDone: Bool
    /// Counts toward today's tally: a habit to do, not skipped today.
    let counts: Bool

    init(habit: Habit, progress: HabitProgress, today: LogicalDay) {
        hasCheckbox = progress.limit == nil
        isChecked = hasCheckbox && habit.isDone(on: today)
        countsTimes = hasCheckbox && habit.timesPerDay(on: today) > 1
        isDone = isChecked || (hasCheckbox && progress.isComplete)
        counts = hasCheckbox && progress.isSkippedToday == false
    }
}
