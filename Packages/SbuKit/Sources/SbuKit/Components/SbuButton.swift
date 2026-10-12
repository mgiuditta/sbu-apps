import SwiftUI

/// A full-width 50pt button in one of the three Sbu roles.
///
/// Labels are infinitive verbs ("Aggiungi abbonamento"). Use one primary per screen, at the
/// bottom. The destructive role asks for confirmation before running its action.
public struct SbuButton: View {
    private let title: LocalizedStringKey
    private let kind: Kind
    private let action: () -> Void

    @State private var isConfirming = false

    /// Creates a button.
    /// - Parameters:
    ///   - title: An infinitive verb, such as "Esporta CSV".
    ///   - kind: Primary, secondary or destructive.
    ///   - action: Runs on tap; for `.destructive`, only after the user confirms.
    public init(_ title: LocalizedStringKey, kind: Kind = .primary, action: @escaping () -> Void) {
        self.title = title
        self.kind = kind
        self.action = action
    }

    public var body: some View {
        Button(title, role: kind == .destructive ? .destructive : nil, action: tap)
            .buttonStyle(SbuButtonStyle(kind: kind))
            .confirmationDialog(title, isPresented: $isConfirming, titleVisibility: .visible) {
                Button(title, role: .destructive, action: action)
            }
    }

    private func tap() {
        if kind == .destructive {
            isConfirming = true
        } else {
            action()
        }
    }
}

#Preview("Light") {
    SbuButtonPreview()
}

#Preview("Dark") {
    SbuButtonPreview()
        .preferredColorScheme(.dark)
}

private struct SbuButtonPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            SbuButton("Aggiungi abbonamento") {}
            HStack(spacing: SbuTheme.space3) {
                SbuButton("Esporta CSV", kind: .secondary) {}
                SbuButton("Elimina", kind: .destructive) {}
            }
            SbuButton("Disattivato") {}
                .disabled(true)
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSubscriptions)
    }
}
