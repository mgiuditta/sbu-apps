import SwiftUI
import WidgetKit

/// The small widget for one habit: its ring and Serie, marked with a tap.
struct SingleHabitWidget: Widget {
    static let kind = "dev.sbu.habits.single"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: SingleHabitProvider()) { entry in
            SingleHabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Un'abitudine")
        .description("L'anello e la serie di un'abitudine.")
        .supportedFamilies([.systemSmall])
    }
}
