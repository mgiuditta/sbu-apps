import SwiftData

/// Every shipped schema, oldest first; add a stage with each new version.
nonisolated enum SubscriptionsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SubscriptionsSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
