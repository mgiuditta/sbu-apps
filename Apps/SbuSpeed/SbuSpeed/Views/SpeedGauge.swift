import SbuKit
import SwiftUI

/// A thin dial arc: the track in `line`, the current speed in the accent. Decorative: the speed is in the figure.
struct SpeedGauge: View {
    /// Speed over full scale, clamped to 0...1.
    let fraction: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            DialArc()
                .stroke(SbuTheme.line, style: StrokeStyle(lineWidth: SbuTheme.space2))

            DialArc(fraction: fraction)
                .stroke(.tint, style: StrokeStyle(lineWidth: SbuTheme.space2))
        }
        // Half the line width, so the stroke stays inside the frame.
        .padding(SbuTheme.space1)
        .aspectRatio(DialArc.aspectRatio, contentMode: .fit)
        .animation(reduceMotion ? nil : .easeOut, value: fraction)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    SpeedGaugePreview()
}

#Preview("Dark") {
    SpeedGaugePreview()
        .preferredColorScheme(.dark)
}

private struct SpeedGaugePreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            SpeedGauge(fraction: 0.26)
            SpeedGauge(fraction: 1)
        }
        .frame(maxWidth: 200)
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
    }
}
