import SbuKit
import SwiftUI

/// The one figure of the finder: the signal as a percentage, as in Find Air, closed by the full
/// stop; under it the word, or how long the device has been silent.
struct FinderFigure: View {
    let tracked: TrackedDevice?

    @ScaledMetric(relativeTo: .largeTitle) private var valueSize = SbuTheme.statHeroSize

    private var percent: Double { tracked?.device.proximity.percent ?? 0 }

    private var contextText: Text {
        guard let tracked else { return Text(Warmth.cold.name) }
        if tracked.silence > TrackedDevice.longAgo {
            return Text("Non nelle vicinanze")
        }
        if tracked.isLost {
            let silence = tracked.silenceDuration.formatted(.units(allowed: [.minutes, .seconds], width: .abbreviated))
            return Text("Non sentito da \(silence)")
        }
        return Text(tracked.warmth.name)
    }

    private var contextSystemImage: String {
        guard let tracked else { return Warmth.cold.systemImage }
        return tracked.isLost ? "antenna.radiowaves.left.and.right.slash" : tracked.warmth.systemImage
    }

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(percent, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.numberFont(size: valueSize))
                    .tracking(SbuTheme.statHeroTracking)
                    // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                    .padding(.trailing, -SbuTheme.statHeroTracking)
                    .foregroundStyle(SbuTheme.ink)
                    .contentTransition(.numericText(value: percent))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                SbuFullStop(fontSize: valueSize)
            }
            .animation(.smooth, value: percent)

            HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
                Image(systemName: contextSystemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
                contextText
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Segnale"))
        .accessibilityValue(Text("\(Text(percent, format: .percent.precision(.fractionLength(0)))), \(contextText)"))
        .accessibilityIdentifier("figure")
    }
}

#Preview("Light") {
    FinderFigure(tracked: TrackedDevice(
        device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -55, lastSeen: .now),
        warmth: .hot,
        silence: 0
    ))
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    FinderFigure(tracked: TrackedDevice(
        device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -70, lastSeen: .now),
        warmth: .warm,
        silence: 8
    ))
    .tint(SbuTheme.accentFind)
    .preferredColorScheme(.dark)
}
