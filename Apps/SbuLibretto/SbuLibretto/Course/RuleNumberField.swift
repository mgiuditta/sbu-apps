import SbuKit
import SwiftUI

/// A number of the course rules, typed: it is saved as soon as it reads as a number, and Settings
/// keeps it in range. While the text is not a number, the saved value stays.
struct RuleNumberField: View {
    let title: LocalizedStringKey
    @Binding var value: Double
    var unit: LocalizedStringKey?
    /// Bonus points can be negative: the decimal keypad has no minus.
    var allowsNegative = false
    var identifier = ""

    @Environment(\.locale) private var locale
    @State private var text = ""
    @FocusState private var isEditing: Bool

    var body: some View {
        NumberField(title: title, text: $text, unit: unit, prompt: "0", identifier: identifier, focus: $isEditing,
                    keyboard: allowsNegative ? .numbersAndPunctuation : .decimalPad)
            .onAppear(perform: showValue)
            .onChange(of: text, save)
            .onChange(of: isEditing) {
                // Leaving the field shows what was saved: in range, as Settings keeps it.
                if !isEditing { showValue() }
            }
            .toolbar {
                if isEditing {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Fine", action: endEditing)
                    }
                }
            }
    }

    private func showValue() {
        text = NumberText.text(value, fractionDigits: 0...4, locale: locale)
    }

    private func save() {
        guard let number = NumberText.double(text, locale: locale), number.isFinite, allowsNegative || number >= 0 else { return }
        value = number
    }

    private func endEditing() {
        isEditing = false
    }
}

#Preview("Light") {
    @Previewable @State var value = 180.0
    Form {
        RuleNumberField(title: "CFU totali", value: $value, unit: "CFU")
    }
}

#Preview("Dark") {
    @Previewable @State var value = 3.0
    Form {
        RuleNumberField(title: "Bonus", value: $value, unit: "punti", allowsNegative: true)
    }
    .preferredColorScheme(.dark)
}
