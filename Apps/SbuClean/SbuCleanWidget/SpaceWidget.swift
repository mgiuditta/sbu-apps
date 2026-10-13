import SwiftUI
import WidgetKit

/// The iPhone's free space as one figure, and what Sbu Clean found you can free. Tapping it
/// opens the app.
struct SpaceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshot.widgetKind, provider: SpaceProvider()) { entry in
            SpaceWidgetView(entry: entry)
        }
        .configurationDisplayName("Spazio libero")
        .description("Lo spazio libero sull'iPhone e quello che puoi liberare.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
