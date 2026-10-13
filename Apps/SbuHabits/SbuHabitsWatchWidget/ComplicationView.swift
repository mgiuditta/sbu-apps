import SbuKit
import SwiftUI
import WidgetKit

/// The complication: on a round slot, today's habits done as a ring around the Serie piena; on a
/// rectangle, the Serie piena closed by the full stop over a bar of today's habits done.
struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ComplicationEntry

    var body: some View {
        Group {
            if let today = entry.today {
                switch family {
                case .accessoryRectangular: rectangular(today)
                default: circular(today)
                }
            } else {
                empty
            }
        }
        // On the watch face: no background of its own.
        .containerBackground(for: .widget) {}
    }

    private func circular(_ today: ComplicationToday) -> some View {
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
        .accessibilityValue(value(today))
    }

    private func rectangular(_ today: ComplicationToday) -> some View {
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
        .accessibilityValue(value(today))
    }

    /// No grid for today on the watch: the iPhone sends it when Sbu Habits opens there.
    private var empty: some View {
        Group {
            if family == .accessoryRectangular {
                Text("Apri Sbu Habits sull'iPhone")
                    .font(SbuTheme.footnote)
            } else {
                Image(systemName: "iphone")
                    .font(SbuTheme.title2)
                    .accessibilityLabel(Text("Apri Sbu Habits sull'iPhone"))
            }
        }
    }

    private func value(_ today: ComplicationToday) -> Text {
        Text("\(today.fullStreak) giorni, \(today.done) su \(today.total) oggi")
    }
}

#Preview("Circular", as: .accessoryCircular) {
    HabitsComplication()
} timeline: {
    ComplicationEntry.sample
    ComplicationEntry(date: .now, today: nil)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    HabitsComplication()
} timeline: {
    ComplicationEntry.sample
    ComplicationEntry(date: .now, today: nil)
}
