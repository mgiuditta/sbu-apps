import SbuKit
import SwiftUI
import WidgetKit

/// Completions on each day of the week since the habit began, as in Streaks: one rounded accent
/// bar a day, from the first day of the user's week, its initial under it. A day without any is
/// a faint dot, so the seven stay in place.
struct WeekdayInsight: View {
    @Environment(\.calendar) private var calendar

    let bars: [WeekdayBar]

    @ScaledMetric(relativeTo: .caption) private var barWidth = SbuTheme.space3

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(bars) { bar in
                VStack(spacing: SbuTheme.space1) {
                    GeometryReader { proxy in
                        // A day without completions is a faint dot, never a short accent bar.
                        Capsule()
                            .fill(bar.count > 0 ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.line))
                            .frame(width: barWidth, height: max(barWidth, proxy.size.height * bar.fraction))
                            .widgetAccentable(bar.count > 0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }

                    Text(calendar.veryShortStandaloneWeekdaySymbols[bar.weekday - 1])
                        .font(SbuTheme.caption)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .dynamicTypeSize(...DynamicTypeSize.xLarge)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(calendar.standaloneWeekdaySymbols[bar.weekday - 1]))
                .accessibilityValue(Text(bar.count, format: .number))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Completamenti per giorno della settimana"))
    }
}

#Preview("Light") {
    WeekdayInsightPreview()
}

#Preview("Dark") {
    WeekdayInsightPreview()
        .preferredColorScheme(.dark)
}

private struct WeekdayInsightPreview: View {
    var body: some View {
        WeekdayInsight(bars: WeekdayBar.bars(from: [2, 3, 4, 5, 6, 7, 1].enumerated().map { WeekdayCount(weekday: $1, count: [9, 8, 5, 7, 4, 10, 0][$0]) }))
            .frame(width: 138, height: 90)
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
