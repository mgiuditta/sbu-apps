import SwiftUI
import WidgetKit

/// A one-habit widget from Streaks: the completion rate since the habit began, as a line.
struct RateWidget: Widget {
    static let kind = "dev.sbu.habits.rate"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: HabitInsightProvider(insight: .rate)) { entry in
            HabitInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Completamento")
        .description("Il completamento di un'abitudine nel tempo.")
        .supportedFamilies([.systemSmall])
    }
}
