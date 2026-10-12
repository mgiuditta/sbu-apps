import SbuKit
import SwiftUI

/// Bubble in a circle when flat, a rotating bar when on an edge. Decorative: the angle is in the stat.
struct LevelIndicator: View {
    let reading: LevelReading

    @ScaledMetric private var bubbleSide: CGFloat = 48

    var body: some View {
        ZStack {
            Circle()
                .fill(SbuTheme.surfaceSunken)

            Circle()
                .stroke(SbuTheme.line, lineWidth: SbuTheme.hairline)
                .frame(width: bubbleSide + SbuTheme.space2, height: bubbleSide + SbuTheme.space2)
                .opacity(reading.mode == .flat ? 1 : 0)

            Rectangle()
                .fill(SbuTheme.line)
                .frame(height: SbuTheme.hairline)

            Capsule()
                .fill(.tint)
                .frame(height: SbuTheme.space2)
                .padding(.horizontal, SbuTheme.space6)
                .rotationEffect(.degrees(reading.angle))
                .opacity(reading.mode == .edge ? 1 : 0)

            BubbleView(reading: reading, side: bubbleSide)
                .opacity(reading.mode == .flat ? 1 : 0)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

/// The bubble, offset within the indicator by the reading.
private struct BubbleView: View {
    let reading: LevelReading
    let side: CGFloat

    var body: some View {
        Circle()
            .fill(.tint)
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .visualEffect { content, proxy in
                // Travel up to the indicator's radius, minus the bubble.
                let travel = (proxy.size.width - side) / 2
                return content.offset(x: reading.bubbleX * travel, y: reading.bubbleY * travel)
            }
    }
}

#Preview("Light") {
    LevelIndicatorPreview()
}

#Preview("Dark") {
    LevelIndicatorPreview()
        .preferredColorScheme(.dark)
}

private struct LevelIndicatorPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            LevelIndicator(reading: LevelReading(mode: .flat, angle: 3, bubbleX: 0.4, bubbleY: -0.2))
            LevelIndicator(reading: LevelReading(mode: .edge, angle: 12, bubbleX: 0, bubbleY: 0))
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
    }
}
