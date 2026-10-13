/// The symbol before a habit's title, as Streaks draws it: a heart when Salute marks it, ⊘ for
/// an Abitudine da evitare, nothing for any other. Shared by the grid and the widgets.
nonisolated enum HabitKindMark {
    static func symbol(of habit: Habit) -> String? {
        if habit.health != nil {
            "heart.fill"
        } else if habit.limit != nil {
            "nosign"
        } else {
            nil
        }
    }
}
