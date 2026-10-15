import SbuKit
import SwiftUI

/// A form row for a number: its name on the left, the value and its unit on the right, decimal keypad.
struct NumberField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let unit: String
    var identifier = ""

    var body: some View {
        LabeledContent {
            HStack(spacing: SbuTheme.space1) {
                TextField(text: $text, prompt: Text(verbatim: "0")) {
                    Text(title)
                }
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                // The unit is hidden beside the field: VoiceOver hears it with the name.
                .accessibilityLabel(Text("\(Text(title)), \(unit)"))
                .accessibilityIdentifier(identifier)
                Text(unit)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
        } label: {
            Text(title)
        }
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
