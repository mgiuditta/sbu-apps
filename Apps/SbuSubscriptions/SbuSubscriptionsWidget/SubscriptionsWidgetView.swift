import SbuKit
import SwiftUI
import WidgetKit

/// The figure closed by the full stop, what it counts and, where there's room, the next payment.
struct SubscriptionsWidgetView: View {
    let entry: SubscriptionsWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        SbuWidgetFigure(
            value: entry.total.formatted(.currency(code: entry.currencyCode)),
            label: label,
            // Waiting while there is nothing to count; set on the total.
            fullStop: entry.isEmpty ? .waiting : .set,
            accent: .subscriptions
        )
    }

    private var label: Text {
        if entry.isEmpty { return Text("Nessun abbonamento") }
        guard !family.isAccessory, let next = entry.upcoming.first else { return Text(caption) }
        return Text(caption) + Text(verbatim: "\n") + Text("Prossimo: \(next.name), \(PaymentDayText.text(day: next.day, today: entry.date))")
    }

    private var caption: LocalizedStringKey {
        switch (entry.period, entry.listName) {
        case (.year, nil): "Spendi all'anno"
        case (.month, nil): "Spendi al mese"
        case let (.year, name?): "Spendi all'anno · \(name)"
        case let (.month, name?): "Spendi al mese · \(name)"
        }
    }
}

private extension WidgetFamily {
    var isAccessory: Bool {
        self == .accessoryInline || self == .accessoryRectangular || self == .accessoryCircular
    }
}

#Preview("Small", as: .systemSmall) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Medium", as: .systemMedium) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Large", as: .systemLarge) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Inline", as: .accessoryInline) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}
