import SwiftData

/// The store as shipped in 1.0.
nonisolated enum InventorySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Folder.self, Item.self, ItemPhoto.self, FieldDefinition.self, FieldValue.self] }
}
