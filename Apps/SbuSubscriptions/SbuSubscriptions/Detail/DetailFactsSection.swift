import SbuKit
import SwiftUI

/// The detail's main rows, as in the category's reference apps: billing, next payment, spent so far,
/// how long you've had it, and its category.
struct DetailFactsSection: View {
    let subscription: Subscription
    let tally: SubscriptionTally

    var body: some View {
        let today = Date.now
        Section {
            LabeledContent("Fatturazione") { Text(subscription.cycle.label) }
            LabeledContent("Prossimo pagamento") { Text(nextPaymentText(today: today)) }
            LabeledContent("Speso finora") {
                Text(tally.spent, format: .currency(code: subscription.currencyCode))
            }
            LabeledContent("Abbonato da") {
                if tally.since < Calendar.current.startOfDay(for: today) {
                    Text(tally.since..<today, format: .components(style: .wide, fields: tally.tenureFields(on: today, calendar: .current)))
                } else {
                    Text("Oggi")
                }
            }
            LabeledContent("Categoria") {
                if let category = subscription.category {
                    HStack(spacing: SbuTheme.space2) {
                        Image(systemName: category.symbol)
                            .fontWeight(.medium)
                            .imageScale(.medium)
                            .accessibilityHidden(true)
                        Text(category.name)
                    }
                } else {
                    Text("Nessuna")
                }
            }
        }
    }

    private func nextPaymentText(today: Date) -> LocalizedStringKey {
        switch subscription.status {
        case .paused: return "In pausa"
        case .cancelled: return "Annullato"
        case .active: break
        }
        guard let next = subscription.nextPayment(after: today) else { return "Concluso" }
        return "\(next.formatted(.dateTime.day().month(.abbreviated).year()))"
    }
}

#Preview("Light") {
    List { DetailFactsSection(subscription: .preview, tally: Subscription.preview.tally()) }
        .modelContainer(.preview)
}

#Preview("Dark") {
    List { DetailFactsSection(subscription: .preview, tally: Subscription.preview.tally()) }
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
