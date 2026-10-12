import SwiftUI

/// The full stop: a square in the app's accent that closes the one figure of a screen.
///
/// Its side is `markSize` and its gap from the last character is `markGap`, both relative to the
/// font size of the figure it closes, and it sits on the baseline. Place it last in an
/// `HStack(alignment: .firstTextBaseline, spacing: 0)` with the figure, and pass the same scaled
/// size the figure uses. `SbuStat` and `SbuToolField` already add it: use it directly only for a
/// figure they cannot show. Exactly one per screen, never decorative. VoiceOver skips it.
public struct SbuFullStop: View {
    private let fontSize: CGFloat

    /// Creates the full stop for a figure.
    /// - Parameter fontSize: The point size of the figure it closes, after Dynamic Type scaling.
    public init(fontSize: CGFloat) {
        self.fontSize = fontSize
    }

    public var body: some View {
        let side = fontSize * SbuTheme.markSize
        Rectangle()
            .fill(.tint)
            .frame(width: side, height: side)
            .padding(.leading, fontSize * SbuTheme.markGap)
            // The square's bottom edge rests on the text baseline.
            .alignmentGuide(.firstTextBaseline) { dimensions in dimensions[.bottom] }
            .alignmentGuide(.lastTextBaseline) { dimensions in dimensions[.bottom] }
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    SbuFullStopPreview()
}

#Preview("Dark") {
    SbuFullStopPreview()
        .preferredColorScheme(.dark)
}

private struct SbuFullStopPreview: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statHeroSize

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "2,4°")
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statHeroTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statHeroTracking)
                .foregroundStyle(SbuTheme.ink)
            SbuFullStop(fontSize: size)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
    }
}
