import Foundation

/// The one sheet RootView shows at a time.
enum HabitSheet: Identifiable {
    case add
    case edit(Habit)
    /// The Nota del giorno of a habit on a day.
    case note(Habit, LogicalDay)
    case statistics

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let habit): "edit-\(habit.id)"
        case .note(let habit, let day): "note-\(habit.id)-\(day.ordinal)"
        case .statistics: "statistics"
        }
    }
}
