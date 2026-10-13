import SbuKit
import SwiftUI
import WidgetKit

/// A one-habit widget on paper, in the habits' accent.
struct HabitInsightWidgetView: View {
    let entry: HabitInsightEntry

    var body: some View {
        Group {
            if let content = entry.content {
                HabitInsightView(content: content)
            } else {
                WidgetEmptyText()
            }
        }
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.surface
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
