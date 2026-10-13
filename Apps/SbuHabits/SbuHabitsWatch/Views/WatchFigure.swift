import SbuKit
import SwiftUI

/// The Serie piena at the top of the watch, the screen's one figure: caption, the number in the
/// `stat` face closed by the full stop, "giorni" after it, and a context line.
///
/// `SbuStat` and `SbuToolField` do not fit the wrist (a card, a 64 pt hero and pills), so this is
/// the same type at the watch's scale, without a card.
struct WatchFigure: View {
    let value: Int
    let context: Text

    @ScaledMetric(relativeTo: .title) private var valueSize = SbuTheme.statSize
    @ScaledMetric(relativeTo: .footnote) private var unitSize = SbuTheme.statSmallSize

    /// The word after the figure. Two strings, as Xcode asks for plurals that omit the number.
    private var unit: String {
        " " + (value == 1 ? String(localized: "giorno") : String(localized: "giorni"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text("Serie piena")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(value, format: .number)
                    .font(SbuTheme.numberFont(size: valueSize))
                    .tracking(SbuTheme.statTracking)
                    // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                    .padding(.trailing, -SbuTheme.statTracking)
                    .foregroundStyle(SbuTheme.ink)
                    .contentTransition(.numericText(value: Double(value)))

                Text(unit)
                    .font(SbuTheme.smallNumberFont(size: unitSize))
                    .foregroundStyle(SbuTheme.inkMuted)

                SbuFullStop(fontSize: valueSize)
            }
            .lineLimit(1)

            context
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    WatchFigure(value: 12, context: Text("3 su 5 oggi"))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    WatchFigure(value: 1, context: Text("Tutte fatte"))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
