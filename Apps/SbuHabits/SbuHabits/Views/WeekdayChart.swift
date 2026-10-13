import Charts
import SbuKit
import SwiftUI

/// Completions on each day of the week, from the first day of the user's week: one thin accent
/// bar a day, its initial under it.
struct WeekdayChart: View {
    @Environment(\.calendar) private var calendar

    let weekdays: [WeekdayCount]

    var body: some View {
        Chart(weekdays) { day in
            BarMark(x: .value("Giorno", String(day.weekday)), y: .value("Completamenti", day.count), width: .ratio(0.4))
                .foregroundStyle(.tint)
                .cornerRadius(SbuTheme.radiusSm)
                .accessibilityLabel(Text(calendar.standaloneWeekdaySymbols[day.weekday - 1]))
                .accessibilityValue(Text(day.count, format: .number))
        }
        .chartXScale(domain: weekdays.map { String($0.weekday) })
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let weekday = value.as(String.self).flatMap(Int.init) {
                        Text(calendar.veryShortStandaloneWeekdaySymbols[weekday - 1])
                            .font(SbuTheme.caption)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .accessibilityLabel(Text("Completamenti per giorno della settimana"))
    }
}

#Preview("Light") {
    WeekdayChart(weekdays: (1...7).map { WeekdayCount(weekday: ($0 % 7) + 1, count: $0 * 3) })
        .frame(height: SbuTheme.space12 * 3)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    WeekdayChart(weekdays: (1...7).map { WeekdayCount(weekday: ($0 % 7) + 1, count: $0 * 3) })
        .frame(height: SbuTheme.space12 * 3)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
