import SbuKit
import SwiftUI

/// A whole number you type or step: the field for direct entry, − and + beside it. Never below zero.
///
/// At the accessibility text sizes the title goes on its own line, so it never breaks a letter at a time.
struct QuantityField: View {
    let title: LocalizedStringKey
    @Binding var value: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text(title)
                HStack {
                    field
                    Spacer(minLength: SbuTheme.space2)
                    Stepper(title, value: $value, in: 0...999_999)
                        .labelsHidden()
                        .fixedSize()
                }
            }
        } else {
            Stepper(value: $value, in: 0...999_999) {
                LabeledContent(title) {
                    field
                }
            }
        }
    }

    private var field: some View {
        TextField(title, value: clamped, format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .monospacedDigit()
            // As wide as the number, so the title keeps the room and stays on one line.
            .fixedSize()
            .accessibilityIdentifier("quantityField")
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
        QuantityField(title: "Quantità minima", value: $value)
    }
    .preferredColorScheme(.dark)
}
