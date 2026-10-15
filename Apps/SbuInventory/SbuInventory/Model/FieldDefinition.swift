import Foundation
import SwiftData

/// A field you add to every item, such as Numero di serie or Garanzia fino al.
@Model
final class FieldDefinition {
    var uuid: UUID = UUID()
    var name: String = ""
    /// The raw value of `FieldKind`; a string so an unknown kind from a later version reads as text.
    var kindRaw: String = FieldKind.text.rawValue
    /// Position in the list of fields and in the item form.
    var order: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \FieldValue.definition)
    var values: [FieldValue]? = []

    var kind: FieldKind {
        get { FieldKind(rawValue: kindRaw) ?? .text }
        set { kindRaw = newValue.rawValue }
    }

    init(name: String, kind: FieldKind, order: Int) {
        self.name = name
        self.kindRaw = kind.rawValue
        self.order = order
    }
}
