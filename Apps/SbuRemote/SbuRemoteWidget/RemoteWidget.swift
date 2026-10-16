import SwiftUI
import WidgetKit

/// The interactive remote widget on the Home Screen (iOS 17 `Button(intent:)`).
struct RemoteWidget: Widget {
    static let kind = "dev.sbu.remote.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: RemoteWidgetProvider()) { entry in
            RemoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Telecomando")
        .description("Volume, silenzio, play e accensione dell'ultima TV usata.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
