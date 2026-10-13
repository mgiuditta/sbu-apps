import Charts
import SbuKit
import SwiftUI

/// The completion rate over the period, as in Streaks: an accent line over flat sunken paper,
/// the first day, the number of days and Oggi under it. Each point reads its days and its rate
/// to VoiceOver, and the chart plays as an audio graph. With nothing expected the box stays
/// empty, as the figure already says so; with one point it says there is no line to draw.
struct CompletionLineChart: View {
    @Environment(\.calendar) private var calendar

    let statistics: HabitStatistics

    @ScaledMetric(relativeTo: .body) private var height = SbuTheme.space12 * 3

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            if statistics.canDrawLine {
                chart
            } else if statistics.line.isEmpty {
                // "Niente previsto in questo periodo" is under the figure already.
                emptyBox
                    .accessibilityHidden(true)
            } else {
                Text("Troppo pochi giorni per la linea")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(SbuTheme.space3)
                    .frame(maxWidth: .infinity, minHeight: height)
                    .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusMd))
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: SbuTheme.space2) {
                    firstDay
                    Spacer(minLength: 0)
                    days
                    Spacer(minLength: 0)
                    Text("Oggi")
                }
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    firstDay
                    days
                    Text("Oggi")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(SbuTheme.caption)
            .textCase(.uppercase)
            .tracking(SbuTheme.captionTracking)
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityElement(children: .combine)
        }
    }

    private var chart: some View {
        Chart(statistics.line) { point in
            AreaMark(x: .value("Giorno", point.index), y: .value("Completamento", point.rate))
                .foregroundStyle(SbuTheme.line)
                .interpolationMethod(.monotone)
                .accessibilityHidden(true)
            LineMark(x: .value("Giorno", point.index), y: .value("Completamento", point.rate))
                .foregroundStyle(.tint)
                .lineStyle(StrokeStyle(lineWidth: SbuTheme.hairline * 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)
        }
        .chartXScale(domain: 0...max(statistics.lineLength - 1, 1))
        .chartYScale(domain: 0...1)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: height)
        // Past 20 points Charts reads the line in bins of raw indexes: one element reads better,
        // and the audio graph names every point by its days.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Completamento nel tempo"))
        .accessibilityValue(summary)
        .accessibilityChartDescriptor(CompletionLineDescriptor(points: statistics.line, calendar: calendar))
    }

    private var emptyBox: some View {
        SbuTheme.surfaceSunken
            .frame(maxWidth: .infinity, minHeight: height)
            .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))
    }

    /// The lowest and the highest point.
    private var summary: Text {
        let rates = statistics.line.map(\.rate)
        let format = FloatingPointFormatStyle<Double>.Percent.percent.precision(.fractionLength(0...1))
        return Text("Minimo \((rates.min() ?? 0).formatted(format)), massimo \((rates.max() ?? 0).formatted(format))")
    }

    private var firstDay: Text {
        Text(statistics.firstDay.noon(in: calendar), format: .dateTime.day().month(.abbreviated).year())
    }

    private var days: Text {
        Text("\(statistics.dayCount) giorni")
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    CompletionLineChart(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    CompletionLineChart(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
