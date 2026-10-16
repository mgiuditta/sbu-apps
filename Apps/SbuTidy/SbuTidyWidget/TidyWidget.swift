import SwiftUI
import WidgetKit

/// Today's chores on the Home Screen and the Lock Screen: Tody has no widget.
struct TidyWidget: Widget {
    static let kind = "dev.sbu.tidy.today"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: TidyProvider()) { entry in
            TidyWidgetView(entry: entry)
        }
        .configurationDisplayName("Da fare oggi")
        .description("Quante attività sono da fare e le più urgenti.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}
