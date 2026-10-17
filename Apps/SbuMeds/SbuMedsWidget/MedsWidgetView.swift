import SbuKit
import SwiftUI
import WidgetKit

/// The doses still to take today, closed by the full stop once they are all done, and what the
/// figure counts; on the Home Screen, when the next one is due.
struct MedsWidgetView: View {
    let entry: MedsEntry

    @Environment(\.widgetFamily) private var family

    private var content: WidgetContent { entry.content }

    var body: some View {
        SbuWidgetFigure(
            value: content.toTakeCount.formatted(),
            label: label,
            // Waiting while doses remain or none is due; set once today's are all done.
            fullStop: content.isDone ? .set : .waiting,
            accent: .meds
        )
    }

    private var label: Text {
        if content.isEmpty { return Text("Aggiungi un farmaco") }
        if content.isDone { return Text("Tutto preso") }
        if content.scheduledCount == 0 { return Text("Niente da prendere oggi") }
        let caption = content.lateCount > 0
            ? Text("da prendere oggi · \(content.lateCount) in ritardo")
            : Text("da prendere oggi")
        // The time only, never the medicine's name: the widget can show on a locked iPhone.
        guard !family.isAccessory, let next = content.items.first else { return caption }
        return caption + Text(verbatim: "\n") + Text("Prossima alle \(Text(next.dueDate, format: .dateTime.hour().minute()))")
    }
}

private extension WidgetFamily {
    var isAccessory: Bool {
        self == .accessoryInline || self == .accessoryRectangular || self == .accessoryCircular
    }
}

#Preview("Small", as: .systemSmall) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
    MedsEntry(date: .now, content: WidgetContent(toTakeCount: 0, lateCount: 0, scheduledCount: 4, items: [], isEmpty: false))
}

#Preview("Medium", as: .systemMedium) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}

#Preview("Inline", as: .accessoryInline) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}
