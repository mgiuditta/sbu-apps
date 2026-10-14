import SwiftData

/// Migrations between schema versions; one version so far.
enum ScannerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [ScannerSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
