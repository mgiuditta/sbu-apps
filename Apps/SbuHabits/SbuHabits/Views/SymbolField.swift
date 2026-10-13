import SbuKit
import SwiftUI

/// The form's Simbolo row: the chosen symbol and its name, opening the picker sheet.
struct SymbolField: View {
    @Binding var selection: String

    @State private var isPicking = false

    var body: some View {
        Button(action: pick) {
            LabeledContent {
                HStack(spacing: SbuTheme.space2) {
                    Image(systemName: selection)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.ink)
                    if let symbol = HabitSymbol.named(selection) {
                        Text(symbol.name)
                    }
                    Image(systemName: "chevron.right")
                        .font(SbuTheme.footnote)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(SbuTheme.inkMuted)
            } label: {
                Text("Simbolo")
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        .sheet(isPresented: $isPicking) {
            SymbolPicker(selection: $selection)
        }
    }

    private func pick() {
        isPicking = true
    }
}

#Preview("Light") {
    SymbolFieldPreview()
}

#Preview("Dark") {
    SymbolFieldPreview()
        .preferredColorScheme(.dark)
}

private struct SymbolFieldPreview: View {
    @State private var selection = "book"

    var body: some View {
        Form {
            SymbolField(selection: $selection)
        }
        .tint(SbuTheme.accentHabits)
    }
}
