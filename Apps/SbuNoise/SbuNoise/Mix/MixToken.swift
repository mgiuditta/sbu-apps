import SbuKit
import SwiftUI

/// A sound on the pad: its symbol on `surfaceRaised` and its name, no color of its own; the
/// selection is an accent ring. The variance halo is drawn by the pad, around the sound's place.
struct MixToken: View {
    let sound: Sound
    let isSelected: Bool

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            Image(systemName: sound.systemImage)
                .font(.title3.weight(.medium))
                .foregroundStyle(SbuTheme.ink)
                .frame(width: SbuTheme.controlRound, height: SbuTheme.controlRound)
                .background(SbuTheme.surfaceRaised, in: .circle)
                .overlay {
                    Circle().stroke(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.line), lineWidth: SbuTheme.hairline * 2)
                }
            Text(sound.name)
                .font(.caption2)
                .foregroundStyle(SbuTheme.inkMuted)
                .fixedSize()
        }
    }
}

#Preview("Light") {
    MixToken(sound: Sound.generated[0], isSelected: true)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    MixToken(sound: Sound.generated[3], isSelected: false)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
