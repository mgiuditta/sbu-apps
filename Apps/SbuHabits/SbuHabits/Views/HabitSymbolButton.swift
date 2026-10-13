import SbuKit
import SwiftUI

/// The round "…" on the form's ring: opens the symbol picker sheet. VoiceOver reads the symbol
/// chosen as its value.
struct HabitSymbolButton: View {
    @Binding var selection: String

    @State private var isPicking = false

    var body: some View {
        Button("Cambia simbolo", systemImage: "ellipsis", action: pick)
            .labelStyle(.iconOnly)
            .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm))
            .accessibilityValue(HabitSymbol.named(selection).map { Text($0.name) } ?? Text(verbatim: ""))
            .sheet(isPresented: $isPicking) {
                SymbolPicker(selection: $selection)
            }
    }

    private func pick() {
        isPicking = true
    }
}

#Preview("Light") {
    HabitSymbolButtonPreview()
}

#Preview("Dark") {
    HabitSymbolButtonPreview()
        .preferredColorScheme(.dark)
}

private struct HabitSymbolButtonPreview: View {
    @State private var selection = "book"

    var body: some View {
        HabitSymbolButton(selection: $selection)
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
