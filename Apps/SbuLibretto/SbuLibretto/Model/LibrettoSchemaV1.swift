import SwiftData

/// The first shape of the store: the exams and the weekly lessons.
/// Every attribute has a default, so iCloud can mirror it later (ADR-0008).
enum LibrettoSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Exam.self, Lesson.self]
    }
}
