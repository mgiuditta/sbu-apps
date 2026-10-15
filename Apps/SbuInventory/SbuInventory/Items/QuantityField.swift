import SbuKit
import SwiftUI

/// A whole number you type or step: the field for direct entry, − and + beside it. Never below zero.
struct QuantityField: View {
    let title: LocalizedStringKey
    @Binding var value: Int

    var body: some View {
        Stepper(value: $value, in: 0...999_999) {
            LabeledContent(title) {
                TextField(title, value: clamped, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                    .accessibilityIdentifier("quantityField")
            }
        }
    }

    private var clamped: Binding<Int> {
        Binding { value } set: { value = min(max($0, 0), 999_999) }
    }
}

#Preview("Light") {
    @Previewable @State var value = 3
    Form {
        QuantityField(title: "Quantità", value: $value)
    }
}

#Preview("Dark") {
    @Previewable @State var value = 3
    Form {
        QuantityField(title: "Quantità", value: $value)
    }
    .preferredColorScheme(.dark)
}
