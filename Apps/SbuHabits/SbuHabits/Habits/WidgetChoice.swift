import Foundation

/// What a widget shows once the user's choice in "Modifica widget" is applied.
nonisolated enum WidgetChoice {
    /// Today's grid, narrowed to the chosen habits; all of today's when none is chosen.
    static func grid(_ habits: [Habit], chosen: [UUID], today: LogicalDay, firstWeekday: Int) -> [Habit] {
        let habits = toDo(habits)
        let todays = TodayGrid.habits(habits, on: today, firstWeekday: firstWeekday)
        return chosen.isEmpty ? todays : todays.filter { chosen.contains($0.id) }
    }

    /// The chosen habit, even on a day it is not expected; without a choice, the first one still
    /// to do today, or the first of today's when all are done.
    static func single(_ habits: [Habit], chosen: UUID?, today: LogicalDay, firstWeekday: Int) -> Habit? {
        let habits = toDo(habits)
        if let chosen {
            return habits.first { $0.id == chosen }
        }
        let todays = TodayGrid.habits(habits, on: today, firstWeekday: firstWeekday)
        return todays.first { HabitProgress(of: $0, today: today, firstWeekday: firstWeekday).isComplete == false } ?? todays.first
    }

    /// ponytail: the widget cannot draw an Abitudine da evitare yet; #89 brings them in.
    static func toDo(_ habits: [Habit]) -> [Habit] {
        habits.filter { $0.limit == nil }
    }
}
