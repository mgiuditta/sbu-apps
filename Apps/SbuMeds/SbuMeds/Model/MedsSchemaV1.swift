import SwiftData

/// The store as shipped in 1.0: people, their medicines and each medicine's history.
/// Every attribute has a default and every relationship is optional, so iCloud can mirror it later.
nonisolated enum MedsSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Person.self, Medicine.self, DoseRecord.self] }
}
