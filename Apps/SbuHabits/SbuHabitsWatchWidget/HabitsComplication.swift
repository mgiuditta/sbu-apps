import SwiftUI
import WidgetKit

/// The watch complication, from the grid the watch app keeps: the Serie piena and today's habits done.
@main
struct HabitsComplication: Widget {
    static let kind = "dev.sbu.habits.watch.today"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: ComplicationProvider()) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("Serie piena")
        .description("La serie piena e le abitudini fatte oggi.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
