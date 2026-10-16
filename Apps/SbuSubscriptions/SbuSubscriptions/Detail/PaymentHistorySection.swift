import SbuKit
import SwiftUI

/// The last payments made, newest first, with the pencil that opens the whole history to mark them paid.
struct PaymentHistorySection: View {
    let subscription: Subscription
    let edit: () -> Void

    var body: some View {
        let calendar = Calendar.current
        let payments = PaymentHistory.past(subscription.schedule, through: .now, limit: 3, calendar: calendar)
        let paid = Set((subscription.events ?? []).filter { $0.kind == .paid }.map { calendar.startOfDay(for: $0.date) })
        Section {
            if payments.isEmpty {
                Text("Nessun pagamento ancora")
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            ForEach(payments, id: \.self) { day in
                LabeledContent {
                    HStack(spacing: SbuTheme.space2) {
                        if paid.contains(day) {
                            Label("Pagato", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                                .fontWeight(.medium)
                                .foregroundStyle(SbuTheme.success)
                        }
                        Text(subscription.price(on: day), format: .currency(code: subscription.currencyCode))
                    }
                } label: {
                    Text(day, format: .dateTime.day().month(.abbreviated).year())
                }
            }
        } header: {
            HistoryHeader(title: "Storico dei pagamenti", editLabel: "Modifica lo storico dei pagamenti", edit: edit)
        }
    }
}

#Preview("Light") {
    List { PaymentHistorySection(subscription: .preview) {} }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { PaymentHistorySection(subscription: .preview) {} }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
