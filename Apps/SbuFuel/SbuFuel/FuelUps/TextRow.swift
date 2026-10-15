import SbuKit
import SwiftUI

/// A form row for a short text: its name stays on the left once the field is filled.
struct TextRow: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var prompt: LocalizedStringKey?
    var identifier = ""

    var body: some View {
        LabeledContent {
            TextField(text: $text, prompt: prompt.map { Text($0) }) {
                Text(title)
            }
            .multilineTextAlignment(.trailing)
            .accessibilityIdentifier(identifier)
        } label: {
            Text(title)
        }
    }
}

#Preview("Light") {
    @Previewable @State var text = "Cambio olio"
    Form {
        TextRow(title: "Nome", text: $text)
    }
}

#Preview("Dark") {
    @Previewable @State var text = ""
    Form {
        TextRow(title: "Targa", text: $text, prompt: "Facoltativa")
    }
    .preferredColorScheme(.dark)
}
