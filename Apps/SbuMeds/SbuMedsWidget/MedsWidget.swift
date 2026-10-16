import SwiftUI
import WidgetKit

/// Today's doses on the Home Screen and the Lock Screen, for everyone you look after.
struct MedsWidget: Widget {
    static let kind = "dev.sbu.meds.today"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: MedsProvider()) { entry in
            MedsWidgetView(entry: entry)
        }
        .configurationDisplayName("Da prendere oggi")
        .description("Quante dosi restano oggi e le prossime.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}
