import SwiftData

/// Every shipped schema, oldest first; add a stage with each new version.
nonisolated enum MedsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [MedsSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
