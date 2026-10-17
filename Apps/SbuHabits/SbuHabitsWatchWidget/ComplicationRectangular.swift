import SbuKit
import SwiftUI
import WidgetKit

/// The rectangular complication: the Serie piena as the figure, closed by the full stop once
/// today is done, with today's habits done as its label.
struct ComplicationRectangular: View {
    let today: TodayTally?

    var body: some View {
        if let today {
            SbuWidgetFigure(
                value: today.fullStreak.formatted(),
                label: Text("\(today.done) su \(today.total) oggi"),
                fullStop: today.isComplete && today.fullStreak > 0 ? .set : .waiting,
                accent: .habits
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Serie piena"))
            .accessibilityValue(today.spokenValue)
        } else {
            Text("Apri Sbu Habits sull'iPhone")
                .font(SbuTheme.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .containerBackground(for: .widget) {}
        }
    }
}

#Preview("Light") {
    ComplicationRectangular(today: ComplicationEntry.sample.today)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    ComplicationRectangular(today: nil)
        .preferredColorScheme(.dark)
}
