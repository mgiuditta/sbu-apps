import SwiftUI
import WidgetKit

/// The Home Screen grid: today's habits, or the ones chosen in its settings, marked with a tap.
/// Several of them stacked make pages the user swipes through.
struct HabitsWidget: Widget {
    static let kind = "dev.sbu.habits.today"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitsIntent.self, provider: HabitsTimelineProvider()) { entry in
            HabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Abitudini di oggi")
        .description("Segna le abitudini con un tocco.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
