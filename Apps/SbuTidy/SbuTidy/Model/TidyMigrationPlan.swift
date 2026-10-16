import SwiftData

/// Every shipped schema, oldest first; add a stage with each new version.
nonisolated enum TidyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TidySchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
