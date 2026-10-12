/// Which habits fit in a widget of `capacity` cells: the ones still to do first, so the widget
/// stays useful as the day goes on, then the done ones and the Abitudini da evitare. When they do
/// not all fit, the last cell says how many more.
nonisolated struct WidgetSlots: Equatable, Sendable {
    let shown: [Habit]
    /// Habits left out, shown as "+N" in the last cell; zero when all fit.
    let overflow: Int

    init(_ habits: [Habit], progress: [Habit.ID: HabitProgress], capacity: Int) {
        let toDo = habits.filter { progress[$0.id]?.isStillToDo ?? true }
        let rest = habits.filter { progress[$0.id]?.isStillToDo == false }
        let ordered = toDo + rest
        if ordered.count <= capacity {
            shown = ordered
            overflow = 0
        } else {
            shown = Array(ordered.prefix(capacity - 1))
            overflow = ordered.count - shown.count
        }
    }
}
