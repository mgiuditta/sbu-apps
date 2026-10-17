import SbuKit
import SwiftUI

/// The Serie piena at the top of the watch, the screen's one figure: the number in the figure
/// face closed by the full stop, "giorni" after it, and a context line. The full stop waits while
/// today still asks for something and is set once today is done.
///
/// `SbuFigure` snaps a 144 pt hero to the iPhone's grid, which does not fit the wrist, so this is
/// the same figure at the Live Activity's size, `figureLive`, with the `mark` full stop.
struct WatchFigure: View {
    let value: Int
    let fullStop: SbuFullStop.State
    let context: Text

    /// The word after the figure. Two strings, as Xcode asks for plurals that omit the number.
    private var unit: String {
        " " + (value == 1 ? String(localized: "giorno") : String(localized: "giorni"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(value, format: .number)
                    .font(.sbuFigure(size: SbuTheme.figureLive))
                    .foregroundStyle(SbuTheme.ink)
                    .contentTransition(.numericText(value: Double(value)))

                Text(unit)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)

                SbuFullStop(fullStop, size: .mark)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)

            context
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Serie piena"))
        .accessibilityValue(Text(value, format: .number) + Text(verbatim: unit + ", ") + context)
    }
}

#Preview("Light") {
    WatchFigure(value: 12, fullStop: .waiting, context: Text(verbatim: "3 su 5 oggi"))
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .habits)
}

#Preview("Dark") {
    WatchFigure(value: 1, fullStop: .set, context: Text(verbatim: "1 su 1 oggi"))
        .background(SbuTheme.paper)
        .environment(\.sbuAccent, .habits)
        .preferredColorScheme(.dark)
}
