import Foundation

/// The one sheet RootView shows at a time.
enum HabitSheet: Identifiable {
    /// Aggiungi abitudine: the Modelli and Personalizzata, then the form.
    case add
    case edit(Habit)
    /// The Nota del giorno of a habit on a day.
    case note(Habit, LogicalDay)
    case statistics
    /// An Abitudine condivisa received: its ring, the owner's icon and its statistics.
    case shared(ReceivedHabit)

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let habit): "edit-\(habit.id)"
        case .note(let habit, let day): "note-\(habit.id)-\(day.ordinal)"
        case .statistics: "statistics"
        case .shared(let received): "shared-" + received.key
        }
    }
}
