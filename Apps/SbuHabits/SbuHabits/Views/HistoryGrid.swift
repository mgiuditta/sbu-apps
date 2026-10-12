import SbuKit
import SwiftUI

/// A habit's weeks since it began, up to the last 26, newest first, one column per weekday.
///
/// Done is a filled accent circle with a checkmark, skipped a forward mark, missed an empty
/// ring, and a day with nothing expected stays blank: state never rests on color alone.
struct HistoryGrid: View {
    static let maxWeeks = 26

    @Environment(\.calendar) private var calendar

    let habit: Habit
    let today: LogicalDay
    let firstWeekday: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space1), count: 7)
    }

    private var days: [LogicalDay] {
        let thisWeek = today.weekStart(firstWeekday: firstWeekday)
        let firstWeek = habit.createdOn.weekStart(firstWeekday: firstWeekday)
        // A habit started "in the future", after the clock was moved back, still shows this week.
        let weeks = min(max((thisWeek.ordinal - firstWeek.ordinal) / 7 + 1, 1), Self.maxWeeks)
        return (0..<weeks).flatMap { week in
            (0..<7).map { thisWeek - week * 7 + $0 }
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: SbuTheme.space1) {
            ForEach(0..<7, id: \.self) { offset in
                Text(calendar.veryShortStandaloneWeekdaySymbols[(firstWeekday - 1 + offset) % 7])
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }

            ForEach(days, id: \.self) { day in
                HistoryCell(state: DayState(of: habit, on: day, today: today), day: day)
            }
        }
        .padding(.vertical, SbuTheme.space2)
    }
}

private struct HistoryCell: View {
    @Environment(\.calendar) private var calendar

    let state: DayState
    let day: LogicalDay

    @ScaledMetric(relativeTo: .body) private var side = SbuTheme.space6

    private var stateName: LocalizedStringKey {
        switch state {
        case .done: "Fatta"
        case .skipped: "Saltata"
        case .missed: "Mancata"
        case .empty: "Non prevista"
        }
    }

    var body: some View {
        ZStack {
            switch state {
            case .done:
                Circle()
                    .fill(.tint)
                Image(systemName: "checkmark")
                    .font(SbuTheme.caption.weight(.semibold))
                    .foregroundStyle(SbuTheme.onAccent)
            case .skipped:
                Image(systemName: "forward")
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
            case .missed:
                Circle()
                    .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline * 2)
            case .empty:
                Color.clear
            }
        }
        .frame(width: side, height: side)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(day.noon(in: calendar), format: .dateTime.weekday(.wide).day().month(.wide)))
        .accessibilityValue(Text(stateName))
        .accessibilityHidden(state == .empty)
    }
}

#Preview("Light") {
    HistoryGridPreview()
}

#Preview("Dark") {
    HistoryGridPreview()
        .preferredColorScheme(.dark)
}

private struct HistoryGridPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", schedule: .weekdays([2, 3, 4, 5, 6]), createdOn: today - 120)
        for daysAgo in stride(from: 1, to: 100, by: 1) where daysAgo % 5 != 0 {
            habit.log[today - daysAgo] = 1
        }
        habit.skipped = [today - 10, today - 25]
        return List {
            HistoryGrid(habit: habit, today: today, firstWeekday: 2)
        }
        .tint(SbuTheme.accentHabits)
    }
}
