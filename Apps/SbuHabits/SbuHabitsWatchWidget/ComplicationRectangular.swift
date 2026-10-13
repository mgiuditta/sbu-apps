import SbuKit
import SwiftUI
import WidgetKit

/// The rectangular complication: the Serie piena closed by the full stop, today's habits done
/// next to it and as a bar under it.
struct ComplicationRectangular: View {
    let today: TodayTally?

    var body: some View {
        if let today {
            VStack(alignment: .leading, spacing: 0) {
                Text("Serie piena")
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(today.fullStreak, format: .number)
                        .font(SbuTheme.numberFont(size: SbuTheme.statSmallSize))
                    SbuFullStop(fontSize: SbuTheme.statSmallSize)
                        .widgetAccentable()
                    Spacer(minLength: SbuTheme.space1)
                    Text("\(today.done) su \(today.total) oggi")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(.secondary)
                }

                Gauge(value: Double(today.done), in: 0...Double(max(today.total, 1))) {
                    EmptyView()
                }
                .gaugeStyle(.linearCapacity)
                .widgetAccentable()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Serie piena"))
            .accessibilityValue(today.spokenValue)
        } else {
            Text("Apri Sbu Habits sull'iPhone")
                .font(SbuTheme.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("Light") {
    ComplicationRectangular(today: ComplicationEntry.sample.today)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    ComplicationRectangular(today: nil)
        .preferredColorScheme(.dark)
}
