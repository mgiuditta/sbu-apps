import SbuKit
import SwiftUI

/// A one-habit picture widget, drawn in `ink` on paper: the habit's small ring and title at the
/// top, the bars per weekday or the month's calendar under them, with no figure to close. The
/// Serie and the completion rate are figures, which `SbuWidgetFigure` draws. A tap opens the app.
struct HabitInsightView: View {
    let content: HabitInsightContent

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            HabitInsightHeader(habit: content.habit, progress: content.progress, streak: content.streak)

            Group {
                switch content.insight {
                case .streak, .rate:
                    EmptyView()
                case .weekdays:
                    if let statistics = content.statistics {
                        WeekdayInsight(bars: WeekdayBar.bars(from: statistics.weekdays))
                    }
                case .calendar:
                    CalendarInsight(dots: content.calendar)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Light") {
    HabitInsightViewPreview()
}

#Preview("Dark") {
    HabitInsightViewPreview()
        .preferredColorScheme(.dark)
}

private struct HabitInsightViewPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 60)
        for daysAgo in 0..<60 where daysAgo % 5 != 3 {
            habit.log[today - daysAgo] = 1
        }
        let habits = [habit]
        return LazyVGrid(columns: [GridItem(.fixed(138)), GridItem(.fixed(138))], spacing: SbuTheme.space8) {
            ForEach([HabitInsight.weekdays, .calendar], id: \.self) { insight in
                if let content = HabitInsightContent(habits: habits, chosen: nil, insight: insight, today: today, firstWeekday: 2) {
                    HabitInsightView(content: content)
                        .frame(width: 138, height: 138)
                }
            }
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
    }
}
