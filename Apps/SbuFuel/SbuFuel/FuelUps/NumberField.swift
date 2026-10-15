import SbuKit
import SwiftUI

/// A form row for a number: its name on the left, the value and its unit on the right, decimal keypad.
struct NumberField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let unit: String
    var identifier = ""
    /// The unit before the number, as "$" in English.
    var unitFirst = false

    var body: some View {
        LabeledContent {
            HStack(spacing: SbuTheme.space1) {
                if unitFirst {
                    Spacer(minLength: 0)
                    unitText
                    field
                        // Hugs the number so the symbol stays beside it, with room enough to tap.
                        .fixedSize()
                        .frame(minWidth: SbuTheme.controlRoundSm, alignment: .leading)
                } else {
                    field
                    unitText
                }
            }
        } label: {
            Text(title)
        }
    }

    private var field: some View {
        TextField(text: $text, prompt: Text(verbatim: "0")) {
            Text(title)
        }
        .keyboardType(.decimalPad)
        .multilineTextAlignment(unitFirst ? .leading : .trailing)
        .monospacedDigit()
        // The unit is hidden beside the field: VoiceOver hears it with the name.
        .accessibilityLabel(Text("\(Text(title)), \(unit)"))
        .accessibilityIdentifier(identifier)
    }

    private var unitText: some View {
        Text(unit)
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityHidden(true)
    }

    /// Whether the locale writes its currency symbol before the amount.
    static func currencySymbolFirst(locale: Locale) -> Bool {
        let code = Money.currencyCode(for: locale)
        let sample = Decimal(1).formatted(.currency(code: code).locale(locale))
        return !(sample.first?.isNumber ?? true)
    }
}

#Preview("Light") {
    @Previewable @State var text = "45210"
    Form {
        NumberField(title: "Contachilometri", text: $text, unit: "km")
    }
}

#Preview("Dark") {
    @Previewable @State var text = ""
    Form {
        NumberField(title: "Quantità", text: $text, unit: "L")
    }
    .preferredColorScheme(.dark)
}
