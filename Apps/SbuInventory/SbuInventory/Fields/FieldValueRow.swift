import SbuKit
import SwiftUI

/// One custom field of an item, read only, formatted for its kind.
struct FieldValueRow: View {
    let value: FieldValue

    var body: some View {
        let name = value.definition?.name ?? ""
        switch value.definition?.kind ?? .text {
        case .text:
            LabeledContent(name, value: value.text ?? "")
        case .number:
            LabeledContent(name) {
                if let number = value.number { Text(number, format: .number) } else { Text(value.text ?? "") }
            }
        case .money:
            LabeledContent(name) {
                if let number = value.number { Text(number, format: InventoryCurrency.format) } else { Text(value.text ?? "") }
            }
        case .date:
            LabeledContent(name) {
                if let date = value.date { Text(date, format: .dateTime.day().month(.wide).year()) } else { Text(value.text ?? "") }
            }
        }
    }
}

#Preview("Light") {
    let value = FieldValue(definition: FieldDefinition(name: "Numero di serie", kind: .text, order: 0), item: Item(name: "Trapano"))
    value.text = "SN-42"
    return List { FieldValueRow(value: value) }
}

#Preview("Dark") {
    let value = FieldValue(definition: FieldDefinition(name: "Garanzia fino al", kind: .date, order: 0), item: Item(name: "Trapano"))
    value.date = .now
    return List { FieldValueRow(value: value) }
        .preferredColorScheme(.dark)
}
