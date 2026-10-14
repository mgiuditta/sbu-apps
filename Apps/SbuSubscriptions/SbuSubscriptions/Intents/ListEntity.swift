import AppIntents
import SwiftData

/// One of your lists, for the widget's settings and Shortcuts.
struct ListEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Lista"
    static let defaultQuery = ListEntityQuery()

    /// The list's name: unique enough to pick it, and stable when the store syncs.
    let id: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

struct ListEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ListEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ListEntity] {
        try await MainActor.run {
            let context = ModelContext(try ModelContainer.subscriptions())
            return try context.fetch(FetchDescriptor<SubscriptionList>(sortBy: [SortDescriptor(\.order)])).map { ListEntity(id: $0.name) }
        }
    }
}
