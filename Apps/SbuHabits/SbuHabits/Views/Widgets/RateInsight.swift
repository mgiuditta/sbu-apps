import Charts
import SbuKit
import SwiftUI
import WidgetKit

/// The completion rate since the habit began, as in Streaks: the accent line over the flat area,
/// the first day under its start and Oggi under its end. The same line as the Statistiche page.
struct RateInsight: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.widgetRenderingMode) private var renderingMode

    let statistics: HabitStatistics

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            if statistics.line.isEmpty {
                Text("Niente previsto in questo periodo")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                chart
            }

            HStack(spacing: SbuTheme.space2) {
                Text(statistics.firstDay.noon(in: calendar), format: .dateTime.day().month(.abbreviated).year(.twoDigits))
                Spacer(minLength: 0)
                Text("Oggi")
            }
            .font(SbuTheme.caption)
            .textCase(.uppercase)
            .tracking(SbuTheme.captionTracking)
            .foregroundStyle(SbuTheme.inkMuted)
            .lineLimit(1)
            .dynamicTypeSize(...DynamicTypeSize.xLarge)
            .accessibilityElement(children: .combine)
        }
    }

    private var chart: some View {
        Chart(statistics.line) { point in
            AreaMark(x: .value("Giorno", point.index), y: .value("Completamento", point.rate))
                .foregroundStyle(WidgetTrack.style(for: renderingMode))
                .interpolationMethod(.monotone)
            LineMark(x: .value("Giorno", point.index), y: .value("Completamento", point.rate))
                .foregroundStyle(.tint)
                .lineStyle(StrokeStyle(lineWidth: SbuTheme.hairline * 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)
            if statistics.line.count == 1 {
                PointMark(x: .value("Giorno", point.index), y: .value("Completamento", point.rate))
                    .foregroundStyle(.tint)
            }
        }
        .chartXScale(domain: 0...max(statistics.lineLength - 1, 1))
        .chartYScale(domain: 0...1)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        // The line's stroke at 100 % would be cut in half by the edge.
        .padding(.vertical, SbuTheme.hairline)
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Completamento nel tempo"))
        .accessibilityValue(summary)
    }

    /// The lowest and the highest point, as the Statistiche read them.
    private var summary: Text {
        let rates = statistics.line.map(\.rate)
        let format = FloatingPointFormatStyle<Double>.Percent.percent.precision(.fractionLength(0...1))
        return Text("Minimo \((rates.min() ?? 0).formatted(format)), massimo \((rates.max() ?? 0).formatted(format))")
    }
}

#Preview("Light") {
    RateInsightPreview()
}

#Preview("Dark") {
    RateInsightPreview()
        .preferredColorScheme(.dark)
}

private struct RateInsightPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 90)
        for daysAgo in 0..<90 where daysAgo % 3 != 0 || daysAgo < 20 {
            habit.log[today - daysAgo] = 1
        }
        return RateInsight(statistics: .habit(habit, period: .all, today: today, firstWeekday: 2))
            .frame(width: 138, height: 90)
            .padding(SbuTheme.space4)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentHabits)
    }
}
