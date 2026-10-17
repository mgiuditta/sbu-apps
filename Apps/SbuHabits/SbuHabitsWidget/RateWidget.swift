import SwiftUI
import WidgetKit

/// A one-habit widget: the completion rate since the habit began, as the figure.
struct RateWidget: Widget {
    static let kind = "dev.sbu.habits.rate"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: HabitInsightProvider(insight: .rate)) { entry in
            HabitInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Completamento")
        .description("Il completamento di un'abitudine da quando hai iniziato.")
        .supportedFamilies([.systemSmall])
    }
}
