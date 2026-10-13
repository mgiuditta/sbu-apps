import Foundation

/// What the form's goal row sets, which depends on the kind; `HabitDraft.goal` is `nil` when
/// there is nothing to set, as for a habit counted in weeks or months.
nonisolated enum HabitGoal: Hashable, Sendable {
    /// Times per day of a habit to do.
    case timesPerDay
    /// The Limite of an Abitudine da evitare.
    case limit
    /// The countdown of an Abitudine a tempo.
    case duration
    /// The daily goal in Salute of a linked habit.
    case health

    /// The row's name: Limite and Durata say what they set, the others are an Obiettivo.
    var title: LocalizedStringResource {
        switch self {
        case .timesPerDay, .health: "Obiettivo"
        case .limit: "Limite"
        case .duration: "Durata"
        }
    }
}
