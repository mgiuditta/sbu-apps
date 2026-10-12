import AppIntents
import Foundation

/// A habit as the widget's settings list it: what "Modifica widget" lets the user pick.
nonisolated struct HabitEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Abitudine"
    static let defaultQuery = HabitEntityQuery()

    let id: UUID
    let title: String
    let symbol: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", image: .init(systemName: symbol))
    }

    init(_ habit: Habit) {
        id = habit.id
        title = habit.title
        symbol = habit.symbol
    }
}
