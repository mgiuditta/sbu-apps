import SwiftData

/// The store as shipped in 2.0.
nonisolated enum SubscriptionsSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Subscription.self, SubscriptionCategory.self, SubscriptionList.self] }
}
