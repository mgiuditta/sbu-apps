import SbuKit
import SwiftUI

/// One page of the player: the sound's or mix's symbol where the original shows a photo, then its
/// name as the screen's figure, closed by the full stop.
struct PlayerPage: View {
    let item: PlayerItem
    let position: Int
    let count: Int

    @ScaledMetric(relativeTo: .largeTitle) private var nameSize = SbuTheme.statSize
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 120

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            Spacer(minLength: 0)
            Image(systemName: item.systemImage)
                .font(.system(size: symbolSize, weight: .medium))
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(item.name)
                    .font(SbuTheme.numberFont(size: nameSize))
                    .tracking(SbuTheme.statTracking)
                    // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                    .padding(.trailing, -SbuTheme.statTracking)
                    .foregroundStyle(SbuTheme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                SbuFullStop(fontSize: nameSize)
            }
            .accessibilityAddTraits(.isHeader)
            Group {
                switch item {
                case .sound: Text("Suoni · \(position) di \(count)")
                case .mix: Text("Mix · \(position) di \(count)")
                }
            }
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(SbuTheme.space4)
    }
}

#Preview("Light") {
    PlayerPage(item: .sound(Sound.generated[2]), position: 3, count: 5)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    PlayerPage(item: .mix(Mix(name: "Temporale", soundIDs: ["noise.pink"])), position: 1, count: 2)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
