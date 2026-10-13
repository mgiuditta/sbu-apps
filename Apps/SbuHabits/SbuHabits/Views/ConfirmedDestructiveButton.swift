import SbuKit
import SwiftUI

/// `SbuButton(kind: .destructive)`, whose confirmation iOS shows as a small bubble over the
/// button. At the accessibility text sizes the bubble breaks every word in half, so there the
/// same button asks in an alert, which is as wide as the screen. A candidate for SbuKit.
struct ConfirmedDestructiveButton: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: LocalizedStringKey
    /// The question above the confirming button, naming what goes.
    let question: LocalizedStringKey
    let action: () -> Void

    @State private var isConfirming = false

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            // SbuButton draws the button; the clear button over it asks in an alert instead.
            SbuButton(title, kind: .destructive) {}
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .overlay {
                    Button(role: .destructive, action: confirm) {
                        Color.clear
                            .contentShape(.rect(cornerRadius: SbuTheme.radiusLg))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(title))
                }
                .alert(question, isPresented: $isConfirming) {
                    Button(title, role: .destructive, action: action)
                    Button("Annulla", role: .cancel) {}
                }
        } else {
            SbuButton(title, kind: .destructive, confirmationTitle: question, action: action)
        }
    }

    private func confirm() {
        isConfirming = true
    }
}

#Preview("Light") {
    ConfirmedDestructiveButton(title: "Elimina", question: "Eliminare “Leggere”?") {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    ConfirmedDestructiveButton(title: "Elimina", question: "Eliminare “Leggere”?") {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
