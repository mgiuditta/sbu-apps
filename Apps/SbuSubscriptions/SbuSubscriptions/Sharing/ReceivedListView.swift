import SbuKit
import SwiftUI

/// A list someone shares with you, read only: its subscriptions, what it costs, and who shares it.
struct ReceivedListView: View {
    let received: ReceivedList
    let receivedLists: ReceivedLists
    let currency: CurrencySettings

    @AppStorage(TotalPeriod.storageKey, store: .appGroup) private var period = TotalPeriod.year
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .title2) private var totalSize = SbuTheme.statSmallSize

    var body: some View {
        let today = Date.now
        let total = ReceivedListTotal.total(of: received.snapshot, per: period, in: currency.mainCurrency, converter: currency.converter, on: today)
        List {
            Section {
                Text(period == .year ? "\(total.amount.formatted(.currency(code: currency.mainCurrency))) all'anno" : "\(total.amount.formatted(.currency(code: currency.mainCurrency))) al mese")
                    .font(SbuTheme.smallNumberFont(size: totalSize))
                    .foregroundStyle(SbuTheme.ink)
            } footer: {
                if let owner = received.ownerName {
                    Text("Condivisa da \(owner), in sola lettura. Non entra nel tuo totale e non ti manda promemoria.")
                } else {
                    Text("In sola lettura. Non entra nel tuo totale e non ti manda promemoria.")
                }
            }
            Section {
                ForEach(Array(received.snapshot.items.enumerated()), id: \.offset) { _, item in
                    LabeledContent {
                        Text(item.price, format: .currency(code: item.currencyCode))
                    } label: {
                        Text(item.name)
                        Text(item.cycle.label)
                    }
                }
            }
            Section {
                SbuButton("Rimuovi lista", kind: .destructive, confirmationTitle: "Rimuovere \(received.snapshot.name)?", action: remove)
                    .accessibilityIdentifier("removeList")
            } footer: {
                Text("La lista sparisce da questo iPhone. Chi la condivide la tiene.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(received.snapshot.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func remove() {
        let received = received
        Task { await receivedLists.remove(received) }
        dismiss()
    }
}
