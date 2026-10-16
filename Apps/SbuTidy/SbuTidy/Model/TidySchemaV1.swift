import SwiftData

/// The store as shipped in 1.0: rooms, their chores and each chore's history.
/// Every attribute has a default and every relationship is optional, so iCloud can mirror it later.
nonisolated enum TidySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Room.self, Chore.self, Completion.self] }
}
