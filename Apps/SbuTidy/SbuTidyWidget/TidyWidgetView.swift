import SbuKit
import SwiftUI
import WidgetKit

/// The chores to do today, closed by the full stop once none is left, and what the figure counts;
/// on the Home Screen, the most urgent chore.
struct TidyWidgetView: View {
    let entry: TidyEntry

    @Environment(\.widgetFamily) private var family

    private var content: WidgetContent { entry.content }

    var body: some View {
        SbuWidgetFigure(
            value: content.toDoCount.formatted(),
            label: label,
            // Waiting while chores remain or there is no room yet; set once nothing is left to do.
            fullStop: !content.isEmpty && content.toDoCount == 0 ? .set : .waiting,
            accent: .tidy
        )
    }

    private var label: Text {
        if content.isEmpty { return Text("Aggiungi le stanze") }
        if content.toDoCount == 0 { return Text("Casa in ordine") }
        let caption = content.overdueCount > 0
            ? Text("da fare oggi · \(content.overdueCount) in ritardo")
            : Text("da fare oggi")
        guard !family.isAccessory, let first = content.items.first else { return caption }
        return caption + Text(verbatim: "\n") + Text(first.name)
    }
}

private extension WidgetFamily {
    var isAccessory: Bool {
        self == .accessoryInline || self == .accessoryRectangular || self == .accessoryCircular
    }
}

#Preview("Small", as: .systemSmall) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
    TidyEntry(date: .now, content: WidgetContent(toDoCount: 0, overdueCount: 0, items: [], isEmpty: false))
}

#Preview("Medium", as: .systemMedium) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}

#Preview("Inline", as: .accessoryInline) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}
