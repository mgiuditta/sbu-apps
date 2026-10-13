import SbuKit
import SwiftUI
import WidgetKit

/// Plays or pauses the sound on screen through the app, which keeps playing in the background.
struct PlayPauseButton: View {
    let isPlaying: Bool
    /// A filled accent circle on the Home Screen; the bare symbol on the Lock Screen.
    let filled: Bool

    var body: some View {
        Button(intent: SetPlayingIntent(isPlaying: !isPlaying)) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(filled ? .title3.weight(.medium) : .title2.weight(.medium))
                .foregroundStyle(filled ? AnyShapeStyle(SbuTheme.onAccent) : AnyShapeStyle(.primary))
                .frame(width: filled ? SbuTheme.controlRoundSm : nil, height: filled ? SbuTheme.controlRoundSm : nil)
                .background {
                    if filled {
                        Circle().fill(.tint)
                    }
                }
                .widgetAccentable()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPlaying ? Text("Metti in pausa") : Text("Riproduci"))
    }
}
