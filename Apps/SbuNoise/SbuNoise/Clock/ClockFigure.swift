import SbuKit
import SwiftUI

/// The time as the screen's one figure, closed by the full stop: the ringing alarm and the
/// bedside clock.
struct ClockFigure: View {
    let date: Date

    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statHeroSize * 1.5

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(date, format: .dateTime.hour().minute())
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statHeroTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statHeroTracking)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            SbuFullStop(fontSize: size)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(date, format: .dateTime.hour().minute()))
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    ClockFigure(date: .now)
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    ClockFigure(date: .now)
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
