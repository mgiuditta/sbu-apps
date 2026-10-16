import Foundation
import SwiftData

extension ModelContainer {
    /// The app's store, on this device only.
    static func libretto(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: LibrettoSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    /// An in-memory store with the sample libretto, for previews and screenshots.
    static let preview: ModelContainer = {
        do {
            let container = try libretto(inMemory: true)
            SampleLibretto.insert(into: container.mainContext, now: .now)
            return container
        } catch {
            fatalError("Preview store failed to open: \(error)")
        }
    }()
}
