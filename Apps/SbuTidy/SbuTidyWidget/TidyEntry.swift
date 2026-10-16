import Foundation
import WidgetKit

/// The widget at one moment.
struct TidyEntry: TimelineEntry {
    let date: Date
    let content: WidgetContent

    /// For the gallery and the placeholder: made-up, never the user's own.
    static func sample(date: Date = .now) -> TidyEntry {
        func item(_ name: LocalizedStringResource, _ room: LocalizedStringResource, _ label: DueLabel) -> WidgetContent.Item {
            WidgetContent.Item(name: String(localized: name), roomName: String(localized: room), label: label)
        }
        return TidyEntry(date: date, content: WidgetContent(
            toDoCount: 5, overdueCount: 2,
            items: [
                item("Pulire il WC", "Bagno", .late(days: 3)),
                item("Lavare il pavimento", "Cucina", .late(days: 1)),
                item("Lavare i piatti", "Cucina", .today),
                item("Cambiare le lenzuola", "Camera da letto", .today),
                item("Spolverare", "Soggiorno", .today),
            ],
            isEmpty: false
        ))
    }
}
