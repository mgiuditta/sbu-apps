import AppIntents
import Foundation

/// A subscription as Siri, Shortcuts and Spotlight see it: a copy of the fields they show, never the model itself.
struct SubscriptionEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Abbonamento"
    static let defaultQuery = SubscriptionEntityQuery()

    let id: UUID
    @Property(title: "Nome") var name: String
    /// "10,99 € al mese"
    var priceText: String

    init(_ subscription: Subscription) {
        id = subscription.uuid
        priceText = PriceText.text(subscription.price(on: .now), currencyCode: subscription.currencyCode, cycle: subscription.cycle)
        name = subscription.name
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(priceText)")
    }
}
