import SbuKit
import SwiftUI

/// The sound under the bedside clock: its name and play/pause, quiet enough for the dark.
struct ClockSoundRow: View {
    let model: PlayerModel

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Text(model.current?.name ?? String(localized: "Nessun suono"))
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(2)
            Spacer(minLength: 0)
            Button(model.isPlaying ? "Pausa" : "Riproduci", systemImage: model.isPlaying ? "pause.fill" : "play.fill", action: model.togglePlayback)
                .labelStyle(.iconOnly)
                .font(.title3.weight(.medium))
                .foregroundStyle(SbuTheme.ink)
                .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
                .contentShape(.rect)
                .disabled(model.current == nil)
        }
    }
}

#Preview("Light") {
    ClockSoundRow(model: PlayerModel())
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    ClockSoundRow(model: PlayerModel())
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
