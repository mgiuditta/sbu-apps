import Foundation
import SwiftData

extension ModelContainer {
    static let medsAppGroup = "group.dev.sbu.meds"

    /// The app's store, in the App Group so the widget reads the same data. On this device only:
    /// health data never leaves the iPhone.
    static func meds(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: MedsSchemaV1.self)
        if inMemory {
            // A migration plan on an in-memory store makes saves fail: there is nothing to migrate.
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            return try ModelContainer(for: schema, configurations: configuration)
        }
        // On a fresh install the group's Application Support folder does not exist yet, and Core
        // Data logs a failed write before making it; make it first.
        if let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: medsAppGroup) {
            try? FileManager.default.createDirectory(at: group.appending(path: "Library/Application Support"), withIntermediateDirectories: true)
        }
        let configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(medsAppGroup), cloudKitDatabase: .none)
        return try ModelContainer(for: schema, migrationPlan: MedsMigrationPlan.self, configurations: configuration)
    }
}
