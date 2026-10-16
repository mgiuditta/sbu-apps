import Foundation
import SwiftData

extension ModelContainer {
    static let tidyAppGroup = "group.dev.sbu.tidy"

    /// The app's store, in the App Group so the widget reads the same data. On this device only:
    /// no family sync, iCloud would come with ADR-0008, off by default.
    static func tidy(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TidySchemaV1.self)
        if inMemory {
            // A migration plan on an in-memory store makes saves fail: there is nothing to migrate.
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            return try ModelContainer(for: schema, configurations: configuration)
        }
        let configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(tidyAppGroup), cloudKitDatabase: .none)
        return try ModelContainer(for: schema, migrationPlan: TidyMigrationPlan.self, configurations: configuration)
    }

    /// An in-memory store with the sample home, for previews and screenshots.
    static let preview: ModelContainer = {
        do {
            let container = try tidy(inMemory: true)
            SampleHome.insert(into: container.mainContext, now: .now, calendar: .current)
            return container
        } catch {
            fatalError("Preview store failed to open: \(error)")
        }
    }()
}
