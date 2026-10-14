import Foundation
import SwiftData

/// A code made in the creator, kept in its list to show or share again.
@Model
final class CreatedCode {
    var title: String = ""
    var kind: CodeKind = CodeKind.text
    var format: CodeFormat = CodeFormat.qr
    var payload: String = ""
    var created: Date = Date.now

    init(title: String, kind: CodeKind, format: CodeFormat, payload: String, created: Date = .now) {
        self.title = title
        self.kind = kind
        self.format = format
        self.payload = payload
        self.created = created
    }
}
