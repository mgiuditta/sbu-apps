import SbuKit
import SwiftData
import SwiftUI

/// The payments made so far, which you can mark paid, then the prices over time and what happened.
struct HistoryView: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let calendar = Calendar.current
        let payments = PaymentHistory.past(subscription.schedule, through: .now, calendar: calendar)
        let paid = Set((subscription.events ?? []).filter { $0.kind == .paid }.map { calendar.startOfDay(for: $0.date) })
        List {
            Section("Pagamenti") {
                if payments.isEmpty {
                    Text("Nessun pagamento ancora").foregroundStyle(SbuTheme.inkMuted)
                }
                ForEach(payments, id: \.self) { day in
                    PaymentRow(day: day, amount: subscription.price(on: day), currencyCode: subscription.currencyCode,
                               isPaid: paid.contains(day)) { markPaid(day) }
                }
            }
            let changes = (subscription.priceChanges ?? []).sorted { $0.effectiveDate > $1.effectiveDate }
            if !changes.isEmpty {
                Section("Prezzi") {
                    ForEach(changes) { change in
                        LabeledContent {
                            Text(change.price, format: .currency(code: subscription.currencyCode))
                        } label: {
                            Text("Dal \(change.effectiveDate.formatted(.dateTime.day().month(.wide).year()))")
                        }
                    }
                }
            }
            let events = (subscription.events ?? []).filter { $0.kind != .paid }.sorted { $0.date > $1.date }
            if !events.isEmpty {
                Section("Eventi") {
                    ForEach(events) { event in
                        LabeledContent {
                            Text(event.date, format: .dateTime.day().month().year())
                        } label: {
                            Text(title(event))
                        }
                    }
                }
            }
        }
        .navigationTitle("Cronologia")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func title(_ event: SubscriptionEvent) -> LocalizedStringKey {
        switch event.kind {
        case .subscribed: "Iscritto"
        case .paused: "Messo in pausa"
        case .resumed: "Ripreso"
        case .cancelled: "Annullato"
        case .reactivated: "Riattivato"
        case .paid: "Pagato"
        case .priceChanged: "Prezzo cambiato: \(event.amount?.formatted(.currency(code: subscription.currencyCode)) ?? "")"
        }
    }

    private func markPaid(_ day: Date) {
        subscription.record(.paid, date: day, amount: subscription.price(on: day))
        try? modelContext.save()
    }
}

/// One payment made: its day and amount, and whether you marked it paid.
private struct PaymentRow: View {
    let day: Date
    let amount: Decimal
    let currencyCode: String
    let isPaid: Bool
    let markPaid: () -> Void

    var body: some View {
        LabeledContent {
            if isPaid {
                Label("Pagato", systemImage: "checkmark")
                    .foregroundStyle(SbuTheme.success)
            } else {
                Button("Segna come pagato", action: markPaid)
                    .buttonStyle(.borderless)
            }
        } label: {
            VStack(alignment: .leading) {
                Text(day, format: .dateTime.day().month(.wide).year())
                Text(amount, format: .currency(code: currencyCode))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}
