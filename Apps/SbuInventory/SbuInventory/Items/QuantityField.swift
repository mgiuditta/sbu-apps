import SbuKit
import SwiftUI

/// A whole number you type or step: the field for direct entry, − and + beside it. Never below zero.
///
/// On one line when it fits; otherwise, as at the largest text sizes or on a small iPhone, the title goes
/// on its own line above, so it never breaks a letter at a time.
struct QuantityField: View {
    let title: LocalizedStringKey
    @Binding var value: Int

    @ScaledMetric(relativeTo: .body) private var fieldWidth: CGFloat = 56

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SbuTheme.space3) {
                Text(title)
                    .fixedSize()
                Spacer(minLength: SbuTheme.space2)
                controls(alignment: .trailing)
            }
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                controls(alignment: .leading)
            }
        }
    }

    /// The number and − +; the number lines up with the title above it when stacked, with − + beside it in a row.
    private func controls(alignment: TextAlignment) -> some View {
        HStack(spacing: SbuTheme.space3) {
            TextField(title, value: clamped, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(alignment)
                .monospacedDigit()
                .frame(width: fieldWidth)
                .accessibilityIdentifier("quantityField")
            Stepper(title, value: $value, in: 0...999_999)
                .labelsHidden()
                .fixedSize()
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
        QuantityField(title: "Quantità minima", value: $value)
    }
    .preferredColorScheme(.dark)
}
