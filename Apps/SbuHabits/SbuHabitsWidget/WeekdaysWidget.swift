import SwiftUI
import WidgetKit

/// A one-habit widget from Streaks: completions on each day of the week, as bars.
struct WeekdaysWidget: Widget {
    static let kind = "dev.sbu.habits.weekdays"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: HabitInsightProvider(insight: .weekdays)) { entry in
            HabitInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Giorni della settimana")
        .description("I completamenti di un'abitudine per giorno della settimana.")
        .supportedFamilies([.systemSmall])
    }
}
