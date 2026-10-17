import SbuKit
import SwiftUI

/// The last payments made, newest first, each one you can mark paid, with the pencil that opens the whole history.
struct PaymentHistorySection: View {
    let subscription: Subscription
    let edit: () -> Void
    /// Runs once a payment is marked paid here: the detail closes on "Pagato".
    let markedPaid: () -> Void

    @Environment(\.modelContext) private var modelContext

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
                PaymentRow(day: day, amount: subscription.price(on: day), currencyCode: subscription.currencyCode,
                           isPaid: paid.contains(day)) { markPaid(day) }
            }
        } header: {
            HistoryHeader(title: "Storico dei pagamenti", editLabel: "Modifica lo storico dei pagamenti", edit: edit)
        }
    }

    private func markPaid(_ day: Date) {
        subscription.record(.paid, date: day, amount: subscription.price(on: day))
        try? modelContext.save()
        markedPaid()
    }
}

#Preview("Light") {
    List { PaymentHistorySection(subscription: .preview, edit: {}, markedPaid: {}) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { PaymentHistorySection(subscription: .preview, edit: {}, markedPaid: {}) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
