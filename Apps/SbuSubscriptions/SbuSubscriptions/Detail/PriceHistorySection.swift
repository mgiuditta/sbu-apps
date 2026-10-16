import SbuKit
import SwiftUI

/// The prices so far, newest first, with the pencil that changes the price from a given day.
struct PriceHistorySection: View {
    let subscription: Subscription
    let edit: () -> Void

    var body: some View {
        let entries = PriceHistory.entries(price: subscription.price, start: subscription.startDate,
                                           changes: (subscription.priceChanges ?? []).map { ($0.effectiveDate, $0.price) },
                                           through: .now, calendar: .current)
        Section {
            ForEach(entries.prefix(3), id: \.self) { entry in
                LabeledContent {
                    Text(entry.price, format: .currency(code: subscription.currencyCode))
                } label: {
                    Text("Dal \(entry.date.formatted(.dateTime.day().month(.abbreviated).year()))")
                }
            }
        } header: {
            HistoryHeader(title: "Storico dei prezzi", editLabel: "Cambia prezzo", edit: edit)
        }
    }
}

#Preview("Light") {
    List { PriceHistorySection(subscription: .preview) {} }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { PriceHistorySection(subscription: .preview) {} }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
