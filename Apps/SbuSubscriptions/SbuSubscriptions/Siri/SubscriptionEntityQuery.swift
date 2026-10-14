import AppIntents
import SwiftData

/// Finds subscriptions by id or by name, from the app's store.
struct SubscriptionEntityQuery: EntityStringQuery {
    @Dependency private var container: ModelContainer

    @MainActor
    func entities(for identifiers: [SubscriptionEntity.ID]) async throws -> [SubscriptionEntity] {
        try all().filter { identifiers.contains($0.uuid) }.map(SubscriptionEntity.init)
    }

    @MainActor
    func entities(matching string: String) async throws -> [SubscriptionEntity] {
        SubscriptionAnswers.matching(string, in: try all()).map(SubscriptionEntity.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [SubscriptionEntity] {
        try all().filter { $0.status == .active }.map(SubscriptionEntity.init)
    }

    @MainActor
    private func all() throws -> [Subscription] {
        try ModelContext(container).fetch(FetchDescriptor<Subscription>(sortBy: [SortDescriptor(\.name)]))
    }
}
