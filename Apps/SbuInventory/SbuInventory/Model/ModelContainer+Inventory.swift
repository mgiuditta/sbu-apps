import Foundation
import SwiftData

extension ModelContainer {
    /// The inventory store in Application Support, on this iPhone only in 1.0. The model already
    /// follows CloudKit's rules, so opt-in iCloud sync (ADR-0008) needs no migration later.
    /// - Parameter url: A store file of its own, for the UI test that relaunches the app; the default store otherwise.
    static func inventory(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: InventorySchemaV1.self)
        let configuration = if let url {
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        } else {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        }
        return try ModelContainer(for: schema, migrationPlan: InventoryMigrationPlan.self, configurations: configuration)
    }
}
