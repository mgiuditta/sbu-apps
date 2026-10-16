import SbuKit
import SwiftUI

/// The pinned apps under the keys, as text: one tap opens the app on the TV.
struct ShortcutRowView: View {
    let apps: [TVShortcut]
    let session: RemoteSession

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            ForEach(apps) { app in
                Button {
                    Task { await session.run { try await $0.launch(app) } }
                } label: {
                    Text(app.name)
                        .font(SbuTheme.subheadline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusLg))
                .disabled(!session.status.acceptsKeys)
                .accessibilityHint(Text("Apre l'app sulla TV"))
            }
        }
    }
}
