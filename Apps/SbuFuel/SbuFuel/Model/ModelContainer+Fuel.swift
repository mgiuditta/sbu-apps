import Foundation
import SwiftData

extension ModelContainer {
    /// The app's store, on this device only: iCloud sync comes in a later version (ADR-0008).
    static func fuel(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: FuelSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    /// An in-memory store with the sample vehicle, for previews and screenshots.
    static let preview: ModelContainer = {
        do {
            let container = try fuel(inMemory: true)
            SampleData.insert(into: container.mainContext, locale: .current)
            return container
        } catch {
            fatalError("Preview store failed to open: \(error)")
        }
    }()
}
