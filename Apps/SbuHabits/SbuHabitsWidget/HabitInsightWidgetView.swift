import SbuKit
import SwiftUI
import WidgetKit

/// A one-habit widget. The Serie and the completion rate are figures, so `SbuWidgetFigure` draws
/// them, the full stop set once the figure is final; the bars per weekday and the month's
/// calendar are pictures in `ink` on paper, with no figure to close.
struct HabitInsightWidgetView: View {
    let entry: HabitInsightEntry

    var body: some View {
        if let content = entry.content {
            switch content.insight {
            case .streak:
                SbuWidgetFigure(
                    value: content.streak.formatted(),
                    label: Text("Serie di \(content.habit.title)"),
                    // Final once today is done: until then today can still add to it.
                    fullStop: content.streak > 0 && content.progress.isComplete ? .set : .waiting,
                    accent: .habits
                )
            case .rate:
                let rate = content.statistics?.tally.rate
                SbuWidgetFigure(
                    // An en dash, never 0 %, when nothing was expected yet.
                    value: rate?.formatted(.percent.precision(.fractionLength(0))) ?? "–",
                    label: Text("Completamento di \(content.habit.title)"),
                    fullStop: rate == nil ? .absent : .set,
                    accent: .habits
                )
            case .weekdays, .calendar:
                HabitInsightView(content: content)
                    .tint(SbuTheme.ink)
                    .containerBackground(for: .widget) {
                        SbuTheme.paper
                    }
            }
        } else {
            SbuWidgetFigure(value: 0.formatted(), label: Text("Aggiungi un'abitudine nell'app"), fullStop: .waiting, accent: .habits)
        }
    }
}

// The canvas switches light, dark and tinted; the shared views have their own previews.
#Preview("Serie", as: .systemSmall) {
    StreakWidget()
} timeline: {
    HabitInsightEntry.sample(.streak)
    HabitInsightEntry(date: .now, content: nil)
}

#Preview("Completamento", as: .systemSmall) {
    RateWidget()
} timeline: {
    HabitInsightEntry.sample(.rate)
}

#Preview("Giorni della settimana", as: .systemSmall) {
    WeekdaysWidget()
} timeline: {
    HabitInsightEntry.sample(.weekdays)
}

#Preview("Calendario", as: .systemSmall) {
    CalendarWidget()
} timeline: {
    HabitInsightEntry.sample(.calendar)
}
