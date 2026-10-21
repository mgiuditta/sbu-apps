import Charts
import SbuKit
import SwiftUI

/// The last seven days in ink bars, today last, with the Limite di tempo as a dashed line when set.
/// One series, so no legend: the screen's figure names it. VoiceOver reads each bar's day and minutes.
struct WeekChart: View {
    let usage: UsageLog

    var body: some View {
        Chart {
            ForEach(usage.lastSevenDays, id: \.self) { day in
                BarMark(x: .value("Giorno", day, unit: .day), y: .value("Minuti", usage.minutes(on: day)), width: .ratio(0.5))
                    .foregroundStyle(SbuTheme.ink)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: SbuTheme.radiusControl, topTrailingRadius: SbuTheme.radiusControl))
                    .accessibilityLabel(Text(day, format: .dateTime.weekday(.wide)))
                    .accessibilityValue(Text("\(usage.minutes(on: day)) minuti"))
            }
            if usage.limitMinutes > 0 {
                RuleMark(y: .value("Limite", usage.limitMinutes))
                    .foregroundStyle(SbuTheme.inkMuted)
                    .lineStyle(StrokeStyle(lineWidth: SbuTheme.hairline, dash: [SbuTheme.space1]))
                    .accessibilityLabel(Text("Limite di tempo"))
                    .accessibilityValue(Text("\(usage.limitMinutes) minuti"))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(SbuTheme.line)
                AxisValueLabel().foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .frame(height: SbuTheme.gridCell * 8)
    }
}

#Preview("Light") {
    WeekChart(usage: UsageLog(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
}

#Preview("Dark") {
    WeekChart(usage: UsageLog(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .preferredColorScheme(.dark)
}
