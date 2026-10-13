import SwiftUI
import WidgetKit

/// A one-habit widget from Streaks: the Serie in large, closed by the full stop.
struct StreakWidget: Widget {
    static let kind = "dev.sbu.habits.streak"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: HabitInsightProvider(insight: .streak)) { entry in
            HabitInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Serie")
        .description("La serie di un'abitudine, in grande.")
        .supportedFamilies([.systemSmall])
    }
}
