import SbuKit
import SwiftUI

/// The instrument: a clinometer dial with needle and wedge on an edge, a bubble level when flat,
/// cross-fading between the two. Decorative: the angle is in the figure.
struct LevelIndicator: View {
    let reading: LevelReading

    private var isEdge: Bool { reading.mode == .edge }

    var body: some View {
        ZStack {
            ClinometerNeedle(rotation: reading.rotation)
                .opacity(isEdge ? 1 : 0)

            DialScale(showsValues: isEdge)

            BubbleView(bubbleX: reading.bubbleX, bubbleY: reading.bubbleY)
                .opacity(isEdge ? 0 : 1)
        }
        .animation(.easeInOut, value: reading.mode)
        .aspectRatio(1, contentMode: .fit)
        // The dial's marks have a fixed place on the ring: past this size they would overlap.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityHidden(true)
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
            LevelIndicator(reading: LevelReading(gravity: .standing(rotatedBy: 32.4), calibration: .none))
            LevelIndicator(reading: LevelReading(gravity: .lying(tiltedBy: 3), calibration: .none))
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
    }
}
