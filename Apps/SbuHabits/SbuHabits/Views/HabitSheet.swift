import Foundation

/// The one sheet RootView shows at a time.
enum HabitSheet: Identifiable {
    case add
    case edit(Habit)
    case statistics

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let habit): "edit-\(habit.id)"
        case .statistics: "statistics"
        }
    }
}
