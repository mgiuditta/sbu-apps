import Charts
import SbuKit
import SwiftUI

/// Completions by hour of the day, as in Streaks: an accent curve over flat sunken paper, with
/// 06:00 and 18:00 under it.
struct HourChart: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    /// 24 counts, index 0 for 00:00–00:59.
    let hours: [Int]

    var body: some View {
        Chart(hours.indices, id: \.self) { hour in
            AreaMark(x: .value("Ora", hour), y: .value("Completamenti", hours[hour]))
                .foregroundStyle(SbuTheme.line)
                .interpolationMethod(.monotone)
                .accessibilityHidden(true)
            LineMark(x: .value("Ora", hour), y: .value("Completamenti", hours[hour]))
                .foregroundStyle(.tint)
                .lineStyle(StrokeStyle(lineWidth: SbuTheme.hairline * 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.monotone)
        }
        .chartXScale(domain: 0...23)
        .chartXAxis {
            AxisMarks(values: [6, 18]) { value in
                AxisValueLabel {
                    // Whole, at any text size: Charts would otherwise cut 18:00 short at the edge.
                    Text(time(at: value.as(Int.self) ?? 0), format: axisFormat)
                        .font(SbuTheme.caption)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .fixedSize()
                }
            }
        }
        .chartYAxis(.hidden)
        // Charts reads 24 points in bins of raw hours: one element reads better, and the audio
        // graph names every hour.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Completamenti per ora"))
        .accessibilityValue(summary)
        .accessibilityChartDescriptor(HourChartDescriptor(hours: hours, calendar: calendar))
    }

    /// 06:00 and 18:00 on a 24-hour clock; 6 AM and 6 PM on a 12-hour one, where "6:00 PM"
    /// would not fit beside the chart's trailing edge.
    private var axisFormat: Date.FormatStyle {
        switch locale.hourCycle {
        case .oneToTwelve, .zeroToEleven:
            .dateTime.hour(.defaultDigits(amPM: .abbreviated)).locale(locale)
        default:
            .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).locale(locale)
        }
    }

    /// The hour with the most completions.
    private var summary: Text {
        let busiest = hours.indices.max { hours[$0] < hours[$1] } ?? 0
        return Text("Più completamenti alle \(time(at: busiest).formatted(.dateTime.hour().minute()))")
    }

    private func time(at hour: Int) -> Date {
        HourChartDescriptor.time(at: hour, in: calendar)
    }
}

#Preview("Light") {
    HourChart(hours: (0..<24).map { max(0, 12 - abs($0 - 9) * 2) + max(0, 8 - abs($0 - 20) * 2) })
        .frame(height: SbuTheme.space12 * 3)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    HourChart(hours: (0..<24).map { max(0, 12 - abs($0 - 9) * 2) + max(0, 8 - abs($0 - 20) * 2) })
        .frame(height: SbuTheme.space12 * 3)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
