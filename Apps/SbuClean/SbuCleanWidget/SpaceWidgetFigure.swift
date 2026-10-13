import SbuKit
import SwiftUI
import WidgetKit

/// The widget's one figure, closed by the full stop: the hero size while it fits, then `stat`.
struct SpaceWidgetFigure: View {
    let bytes: Int64

    @ScaledMetric(relativeTo: .largeTitle) private var heroSize = SbuTheme.statHeroSize
    @ScaledMetric(relativeTo: .largeTitle) private var statSize = SbuTheme.statSize
    @ScaledMetric(relativeTo: .title2) private var unitSize = SbuTheme.statSmallSize

    var body: some View {
        ViewThatFits(in: .horizontal) {
            figure(size: heroSize, tracking: SbuTheme.statHeroTracking)
            figure(size: statSize, tracking: SbuTheme.statTracking)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(bytes.formatted(.byteCount(style: .file))))
    }

    private func figure(size: CGFloat, tracking: CGFloat) -> some View {
        let figure = SpaceFigure(bytes: bytes)
        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(figure.formattedValue)
                .font(SbuTheme.numberFont(size: size))
                .tracking(tracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -tracking)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .fixedSize()
            Text(figure.unit)
                .font(SbuTheme.smallNumberFont(size: unitSize))
                .foregroundStyle(SbuTheme.inkMuted)
                .fixedSize()
            SbuFullStop(fontSize: size)
                .widgetAccentable()
        }
    }
}

#Preview("Light") {
    SpaceWidgetFigure(bytes: 21_400_000_000)
        .padding()
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    SpaceWidgetFigure(bytes: 840_000_000)
        .padding()
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
