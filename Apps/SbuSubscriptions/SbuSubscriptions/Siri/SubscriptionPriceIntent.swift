import AppIntents
import SwiftData

/// "Quanto costa Musica?"
struct SubscriptionPriceIntent: AppIntent {
    static let title: LocalizedStringResource = "Prezzo di un abbonamento"
    static let description = IntentDescription("Dice quanto costa un abbonamento e ogni quanto lo paghi.")

    @Parameter(title: "Abbonamento")
    var subscription: SubscriptionEntity

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        .result(value: subscription.priceText, dialog: "\(subscription.name) costa \(subscription.priceText).")
    }
}
