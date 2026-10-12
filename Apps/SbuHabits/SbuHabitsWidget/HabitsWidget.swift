import SwiftUI
import WidgetKit

/// The Home Screen widget: today's habits, marked with a tap.
struct HabitsWidget: Widget {
    static let kind = "dev.sbu.habits.today"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HabitsTimelineProvider()) { entry in
            HabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Abitudini di oggi")
        .description("Segna le abitudini con un tocco.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
