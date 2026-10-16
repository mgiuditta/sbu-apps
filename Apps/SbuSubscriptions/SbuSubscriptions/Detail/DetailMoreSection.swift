import SbuKit
import SwiftUI

/// The rest of what you entered: a coming price, the payments left, the trial, the reminder, list, method, site and notes.
struct DetailMoreSection: View {
    let subscription: Subscription

    var body: some View {
        Section {
            if let upcoming {
                LabeledContent("Dal \(upcoming.effectiveDate.formatted(.dateTime.day().month(.wide)))") {
                    Text(upcoming.price, format: .currency(code: subscription.currencyCode))
                }
            }
            if let count = subscription.paymentCount {
                LabeledContent("Pagamenti", value: count, format: .number)
            }
            if let trialEnd = subscription.trialEndDate, subscription.isInTrial() {
                LabeledContent("Prova fino al") { Text(trialEnd, format: .dateTime.day().month(.wide).year()) }
            }
            LabeledContent("Promemoria") { Text(reminderText) }
            if let list = subscription.list {
                LabeledContent("Lista", value: list.name)
            }
            if !subscription.paymentMethod.isEmpty {
                LabeledContent("Metodo di pagamento", value: subscription.paymentMethod)
            }
            if let url = subscription.url, WebPage.isWebPage(url) {
                Link(destination: url) {
                    LabeledContent("Sito") { Text(url.host() ?? url.absoluteString) }
                }
            }
            if !subscription.notes.isEmpty {
                Text(subscription.notes)
            }
        }
    }

    /// The next price change still to come, if any.
    private var upcoming: PriceChange? {
        let today = Calendar.current.startOfDay(for: .now)
        return (subscription.priceChanges ?? []).filter { $0.effectiveDate > today }.min { $0.effectiveDate < $1.effectiveDate }
    }

    private var reminderText: LocalizedStringKey {
        switch subscription.reminderDaysBefore {
        case nil: "Nessuno"
        case 0: "Il giorno stesso"
        case let days?: "^[\(days) giorno](inflect: true) prima"
        }
    }
}

#Preview("Light") {
    List { DetailMoreSection(subscription: .preview) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { DetailMoreSection(subscription: .preview) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
