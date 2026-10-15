import SwiftData

/// Every shipped schema, oldest first; add a stage with each new version.
nonisolated enum InventoryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [InventorySchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
