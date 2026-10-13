import SbuKit
import SwiftUI
import WidgetKit

/// The round complication: today's habits done as a ring around the Serie piena.
struct ComplicationCircular: View {
    let today: TodayTally?

    var body: some View {
        if let today {
            Gauge(value: Double(today.done), in: 0...Double(max(today.total, 1))) {
                Text("Serie piena")
            } currentValueLabel: {
                Text(today.fullStreak, format: .number)
                    .font(SbuTheme.smallNumberFont(size: SbuTheme.statSmallSize))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .widgetAccentable()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Serie piena"))
            .accessibilityValue(today.spokenValue)
        } else {
            Image(systemName: "iphone")
                .font(SbuTheme.title2)
                .fontWeight(.medium)
                .accessibilityLabel(Text("Apri Sbu Habits sull'iPhone"))
        }
    }
}

#Preview("Light") {
    ComplicationCircular(today: ComplicationEntry.sample.today)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    ComplicationCircular(today: nil)
        .preferredColorScheme(.dark)
}
