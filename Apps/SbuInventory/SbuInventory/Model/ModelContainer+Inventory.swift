import Foundation
import SwiftData

extension ModelContainer {
    /// The inventory store in Application Support, on this iPhone only in 1.0. The model already
    /// follows CloudKit's rules, so opt-in iCloud sync (ADR-0008) needs no migration later.
    static func inventory(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: InventorySchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, migrationPlan: InventoryMigrationPlan.self, configurations: configuration)
    }
}
