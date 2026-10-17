import SbuKit
import SwiftUI

/// The Closure of a phase alert turned on: a row of the settings list that is the ink block with
/// "Impostato" and the full stop for two seconds, then goes.
///
/// The row comes in empty and turns the Closure on as it appears, so the Closure's haptic and
/// announcement play once, for this alert.
struct PhaseAlertClosure: View {
    @Binding var isShowing: Bool

    @State private var isClosing = false

    var body: some View {
        // Three cells: room for the word at the Closure's size inside its padding.
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: SbuTheme.gridCell * 3)
            .sbuClosure($isClosing, word: "Impostato")
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .onAppear {
                isClosing = true
            }
            .onChange(of: isClosing) { _, isClosing in
                if isClosing == false { isShowing = false }
            }
    }
}

#Preview("Light") {
    PhaseAlertClosurePreview()
}

#Preview("Dark") {
    PhaseAlertClosurePreview()
        .preferredColorScheme(.dark)
}

private struct PhaseAlertClosurePreview: View {
    @State private var isShowing = true

    var body: some View {
        Form {
            Section {
                Toggle("Luna piena", isOn: .constant(true))
                if isShowing {
                    PhaseAlertClosure(isShowing: $isShowing)
                }
            }
            Button { isShowing = true } label: { Text(verbatim: "Imposta") }
        }
        .environment(\.sbuAccent, .moon)
        .tint(SbuTheme.ink)
    }
}
