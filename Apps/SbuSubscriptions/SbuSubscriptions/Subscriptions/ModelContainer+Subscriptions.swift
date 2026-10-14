import SwiftData

extension ModelContainer {
    static let subscriptionsAppGroup = "group.dev.sbu.subscriptions"

    /// The subscriptions store, in the App Group so the widget reads the same data. iCloud stays off (ADR-0008).
    static func subscriptions(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SubscriptionsSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            groupContainer: inMemory ? .none : .identifier(subscriptionsAppGroup),
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, migrationPlan: SubscriptionsMigrationPlan.self, configurations: configuration)
    }
}
