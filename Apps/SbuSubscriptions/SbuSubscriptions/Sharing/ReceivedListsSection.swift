import SbuKit
import SwiftUI

/// The home's last section: the lists other people share with you, each with what it costs.
struct ReceivedListsSection: View {
    let received: ReceivedLists
    let currency: CurrencySettings
    let period: TotalPeriod

    var body: some View {
        if !received.lists.isEmpty {
            Section("Condivise con te") {
                ForEach(received.lists) { list in
                    NavigationLink {
                        ReceivedListView(received: list, receivedLists: received, currency: currency)
                    } label: {
                        LabeledContent {
                            Text(ReceivedListTotal.total(of: list.snapshot, per: period, in: currency.mainCurrency, converter: currency.converter, on: .now).amount,
                                 format: .currency(code: currency.mainCurrency))
                        } label: {
                            Label {
                                Text(list.snapshot.name)
                                if let owner = list.ownerName { Text(owner) }
                            } icon: {
                                Image(systemName: "person.2")
                                    .fontWeight(.medium)
                                    .foregroundStyle(SbuTheme.inkMuted)
                            }
                        }
                    }
                }
            }
        }
    }
}
