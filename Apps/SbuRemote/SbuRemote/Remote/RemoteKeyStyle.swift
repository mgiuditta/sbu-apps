import SbuKit
import SwiftUI

/// A key of the remote drawn as the instrument: `ink` on raised paper, a `line` border,
/// `radiusCard`. Pressed, the key takes the line's tone; disabled, it dims. No accent.
struct RemoteKeyStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? SbuTheme.ink : SbuTheme.inkMuted)
            .background(configuration.isPressed ? SbuTheme.line : SbuTheme.surfaceRaised,
                        in: .rect(cornerRadius: SbuTheme.radiusCard))
            .overlay {
                RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                    .strokeBorder(SbuTheme.line)
            }
            .contentShape(.rect(cornerRadius: SbuTheme.radiusCard))
            .opacity(isEnabled ? 1 : 0.5)
    }
}

extension ButtonStyle where Self == RemoteKeyStyle {
    /// The remote's own key style.
    static var remoteKey: RemoteKeyStyle { RemoteKeyStyle() }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space4) {
        Button {} label: { Image(systemName: "house").frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm) }
        Button {} label: { Image(systemName: "power").frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm) }
            .disabled(true)
    }
    .buttonStyle(.remoteKey)
    .padding(SbuTheme.space4)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space4) {
        Button {} label: { Image(systemName: "house").frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm) }
        Button {} label: { Image(systemName: "power").frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm) }
            .disabled(true)
    }
    .buttonStyle(.remoteKey)
    .padding(SbuTheme.space4)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
