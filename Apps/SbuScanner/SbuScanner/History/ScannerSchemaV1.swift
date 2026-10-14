import SwiftData

/// The first schema of the Swift app: history, folders and created codes.
enum ScannerSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [ScanRecord.self, ScanFolder.self, CreatedCode.self] }
}
