import Foundation

/// What a widget shows once the user's choice in "Modifica widget" is applied.
nonisolated enum WidgetChoice {
    /// Today's grid, narrowed to the chosen habits; all of today's when none is chosen.
    static func grid(_ habits: [Habit], chosen: [UUID], today: LogicalDay, firstWeekday: Int) -> [Habit] {
        let todays = TodayGrid.habits(habits, on: today, firstWeekday: firstWeekday)
        return chosen.isEmpty ? todays : todays.filter { chosen.contains($0.id) }
    }

    /// The chosen habit, even on a day it is not expected; without a choice, the first one still
    /// to do today, or the first of today's when none is: all done, or all to avoid.
    static func single(_ habits: [Habit], chosen: UUID?, today: LogicalDay, firstWeekday: Int) -> Habit? {
        if let chosen {
            return habits.first { $0.id == chosen }
        }
        let todays = TodayGrid.habits(habits, on: today, firstWeekday: firstWeekday)
        return todays.first { HabitProgress(of: $0, today: today, firstWeekday: firstWeekday).isStillToDo } ?? todays.first
    }
}
