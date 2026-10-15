import SbuKit
import SwiftUI

/// One custom field in the item form, with the input its kind needs.
struct FieldEntryRow: View {
    let definition: FieldDefinition
    @Binding var entry: FieldEntry

    var body: some View {
        input
            .accessibilityIdentifier("field-\(definition.name)")
    }

    @ViewBuilder
    private var input: some View {
        switch definition.kind {
        case .text:
            TextField(definition.name, text: $entry.text, prompt: Text(definition.name))
        case .number:
            LabeledContent(definition.name) {
                TextField(definition.name, value: $entry.number, format: .number, prompt: Text(verbatim: "0"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        case .money:
            LabeledContent(definition.name) {
                TextField(definition.name, value: $entry.number, format: InventoryCurrency.format, prompt: Text(Decimal.zero, format: InventoryCurrency.format))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        case .date:
            OptionalDateRow(title: definition.name, date: $entry.date)
        }
    }
}

#Preview("Light") {
    @Previewable @State var entry = FieldEntry()
    Form {
        FieldEntryRow(definition: FieldDefinition(name: "Riparazione", kind: .money, order: 0), entry: $entry)
    }
}

#Preview("Dark") {
    @Previewable @State var entry = FieldEntry()
    Form {
        FieldEntryRow(definition: FieldDefinition(name: "Numero di serie", kind: .text, order: 0), entry: $entry)
    }
    .preferredColorScheme(.dark)
}
