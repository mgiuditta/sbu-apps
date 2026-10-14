import Foundation
import SwiftData

/// A folder of the history, to keep the codes that matter in one place.
@Model
final class ScanFolder {
    var name: String = ""
    var created: Date = Date.now
    /// The row id in the 1.x database, for codes and folders brought over from it (ADR-0010).
    var legacyID: Int?
    /// Deleting a folder keeps its codes: they go back to the history without a folder.
    @Relationship(deleteRule: .nullify, inverse: \ScanRecord.folder)
    var records: [ScanRecord]? = []

    init(name: String, created: Date = .now) {
        self.name = name
        self.created = created
    }
}
