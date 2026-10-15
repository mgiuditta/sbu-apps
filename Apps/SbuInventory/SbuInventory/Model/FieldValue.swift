import Foundation
import SwiftData

/// What one item has in one custom field: text, a number (money included) or a date, by the field's kind.
@Model
final class FieldValue {
    var definition: FieldDefinition?
    var item: Item?
    var text: String?
    var number: Decimal?
    var date: Date?

    init(definition: FieldDefinition, item: Item) {
        self.definition = definition
        self.item = item
    }
}
