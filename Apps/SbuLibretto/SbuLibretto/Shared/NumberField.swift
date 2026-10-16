import SbuKit
import SwiftUI

/// A form row for a number: its name on the left, the value and its unit on the right, decimal keypad.
struct NumberField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var unit: LocalizedStringKey?
    var prompt = "0"
    var identifier = ""
    /// Where the caller keeps the focus, to close the decimal keypad, which has no return key.
    var focus: FocusState<Bool>.Binding?
    var keyboard = UIKeyboardType.decimalPad

    @FocusState private var ownFocus: Bool

    var body: some View {
        LabeledContent {
            HStack(spacing: SbuTheme.space1) {
                TextField(text: $text, prompt: Text(verbatim: prompt)) {
                    Text(title)
                }
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .focused(focus ?? $ownFocus)
                .accessibilityIdentifier(identifier)
                if let unit {
                    // Visible to VoiceOver too: hidden, the audit flagged it as text shown but not exposed.
                    Text(unit)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        } label: {
            Text(title)
        }
    }
}

#Preview("Light") {
    @Previewable @State var text = "7,5"
    Form {
        NumberField(title: "Crediti", text: $text, unit: "CFU")
    }
}

#Preview("Dark") {
    @Previewable @State var text = ""
    Form {
        NumberField(title: "Crediti", text: $text, unit: "CFU")
    }
    .preferredColorScheme(.dark)
}
