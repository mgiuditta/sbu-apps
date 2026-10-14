import SwiftUI
import WidgetKit

/// What you spend and the payments coming, on the Home Screen and the Lock Screen.
struct SubscriptionsWidget: Widget {
    static let kind = "dev.sbu.subscriptions.upcoming"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseListIntent.self, provider: SubscriptionsTimelineProvider()) { entry in
            SubscriptionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Pagamenti in arrivo")
        .description("Quanto spendi e i prossimi rinnovi.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
    }
}
