import SbuKit
import SwiftUI

/// A thin dial arc: the track in `line`, the current speed in the accent. Decorative: the speed is in the figure.
struct SpeedGauge: View {
    /// The arc spans 240°, open at the bottom like a car's speedometer.
    private static let sweep = 240.0 / 360
    private static let start = Angle.degrees(150)

    /// Speed over full scale, clamped to 0...1.
    let fraction: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: Self.sweep)
                .stroke(SbuTheme.line, style: StrokeStyle(lineWidth: SbuTheme.space2))

            Circle()
                .trim(from: 0, to: Self.sweep * min(1, max(0, fraction)))
                .stroke(.tint, style: StrokeStyle(lineWidth: SbuTheme.space2))
        }
        .rotationEffect(Self.start)
        .padding(SbuTheme.space1)
        .aspectRatio(1, contentMode: .fit)
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
