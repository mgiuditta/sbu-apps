import Foundation
import SwiftData

/// One code read, kept in the history on this iPhone only.
@Model
final class ScanRecord {
    var raw: String = ""
    var symbology: Symbology = Symbology.qr
    var date: Date = Date.now
    var isFavorite: Bool = false
    var folder: ScanFolder?
    /// The row id in the 1.x database, for codes and folders brought over from it (ADR-0010).
    var legacyID: Int?

    init(raw: String, symbology: Symbology, date: Date = .now, folder: ScanFolder? = nil) {
        self.raw = raw
        self.symbology = symbology
        self.date = date
        self.folder = folder
    }

    var content: CodeContent { CodeContent(raw, symbology: symbology) }
}
