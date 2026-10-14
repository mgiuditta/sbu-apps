import AppIntents
import SwiftData

/// "Qual è il prossimo rinnovo?", for one subscription or for all of them.
struct NextRenewalIntent: AppIntent {
    static let title: LocalizedStringResource = "Prossimo rinnovo"
    static let description = IntentDescription("Dice quando arriva il prossimo pagamento e quanto costa.")

    @Parameter(title: "Abbonamento", description: "Lascia vuoto per il primo rinnovo tra tutti.")
    var subscription: SubscriptionEntity?

    @Dependency private var container: ModelContainer

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Date?> & ProvidesDialog {
        let subscriptions = try ModelContext(container).fetch(FetchDescriptor<Subscription>())
        guard let next = SubscriptionAnswers.nextRenewal(subscriptions, of: subscription?.id) else {
            return .result(value: nil, dialog: "Nessun pagamento in arrivo.")
        }
        let day = next.day.formatted(.dateTime.weekday(.wide).day().month(.wide))
        let amount = next.price.formatted(.currency(code: next.currencyCode))
        return .result(value: next.day, dialog: "\(next.name) si rinnova \(day): \(amount).")
    }
}
