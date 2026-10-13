import SwiftUI
import WidgetKit

/// A one-habit widget from Streaks: this month day by day, as dots.
struct CalendarWidget: Widget {
    static let kind = "dev.sbu.habits.calendar"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: HabitInsightProvider(insight: .calendar)) { entry in
            HabitInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Calendario")
        .description("Il mese di un'abitudine, giorno per giorno.")
        .supportedFamilies([.systemSmall])
    }
}
