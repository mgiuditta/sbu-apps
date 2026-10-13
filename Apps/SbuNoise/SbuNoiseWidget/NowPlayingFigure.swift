import SbuKit
import SwiftUI
import WidgetKit

/// The sound's name in the stat face, closed by the full stop, shrinking to fit two lines.
struct NowPlayingFigure: View {
    let name: String

    @ScaledMetric(relativeTo: .title) private var size = SbuTheme.statSize

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(name)
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statTracking)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            SbuFullStop(fontSize: size)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dynamicTypeSize(...DynamicTypeSize.large)
        .accessibilityAddTraits(.isHeader)
    }
}
