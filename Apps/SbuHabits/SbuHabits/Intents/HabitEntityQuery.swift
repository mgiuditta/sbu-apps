import AppIntents
import Foundation

/// Finds habits in the shared file, in the grid's order.
nonisolated struct HabitEntityQuery: EntityQuery {
    func entities(for identifiers: [HabitEntity.ID]) async throws -> [HabitEntity] {
        try HabitsStore.shared.load().habits.filter { identifiers.contains($0.id) }.map(HabitEntity.init)
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        WidgetChoice.toDo(try HabitsStore.shared.load().habits).map(HabitEntity.init)
    }
}
