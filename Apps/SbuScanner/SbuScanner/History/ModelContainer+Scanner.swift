import SwiftData

extension ModelContainer {
    /// The store on this iPhone, never synced: the history stays here.
    static func scanner(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: ScannerSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, migrationPlan: ScannerMigrationPlan.self, configurations: configuration)
    }
}

extension ModelContainer {
    /// In memory, with the demo codes: previews, screenshots, UI tests.
    static var preview: ModelContainer {
        // ponytail: an in-memory store that fails to open is a programming error.
        let container = try! ModelContainer.scanner(inMemory: true)
        DemoContent.seed(container.mainContext)
        return container
    }
}
