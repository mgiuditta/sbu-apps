import SwiftUI
import WidgetKit

/// The weighted average and the next sitting, on the Home Screen and the Lock Screen. Free, unlike in Klim.
struct LibrettoWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshot.widgetKind, provider: LibrettoTimelineProvider()) { entry in
            LibrettoWidgetView(entry: entry)
        }
        .configurationDisplayName("Media e prossimo appello")
        .description("La tua media ponderata e i giorni al prossimo esame.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}
