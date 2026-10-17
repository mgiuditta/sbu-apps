import SwiftUI
import WidgetKit

/// The small widget for one habit: its Serie as the figure, marked with a tap.
struct SingleHabitWidget: Widget {
    static let kind = "dev.sbu.habits.single"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: ChooseHabitIntent.self, provider: SingleHabitProvider()) { entry in
            SingleHabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Un'abitudine")
        .description("La serie di un'abitudine, da segnare con un tocco.")
        .supportedFamilies([.systemSmall])
    }
}
