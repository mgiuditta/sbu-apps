import SbuKit
import SwiftUI

/// One key of the remote: an SF Symbol in a bordered native button, the accent as tint,
/// a light tap of haptics on every press.
struct RemoteKeyButton: View {
    let key: RemoteKey
    let session: RemoteSession
    var side: CGFloat = SbuTheme.controlRound

    @State private var presses = 0

    var body: some View {
        Button(action: press) {
            Image(systemName: key.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .font(SbuTheme.headline)
                .frame(minWidth: side, minHeight: side)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusLg))
        .disabled(!session.isAvailable(key))
        .accessibilityLabel(Text(key.title))
        .sensoryFeedback(.impact(weight: .light), trigger: presses)
    }

    private func press() {
        presses += 1
        Task { await session.press(key) }
    }
}
