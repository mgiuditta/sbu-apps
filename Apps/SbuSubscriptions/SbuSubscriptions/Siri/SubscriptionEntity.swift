import AppIntents
import Foundation

/// A subscription as Siri, Shortcuts and Spotlight see it: a copy of the fields they show, never the model itself.
struct SubscriptionEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Abbonamento"
    static let defaultQuery = SubscriptionEntityQuery()

    let id: UUID
    @Property(title: "Nome") var name: String
    /// "10,99 € al mese": what Siri says once the iPhone is unlocked, never shown in Spotlight.
    var priceText: String
    /// "Mensile": the only detail Spotlight and the Shortcuts pickers show.
    var cycleText: String

    init(_ subscription: Subscription) {
        id = subscription.uuid
        priceText = PriceText.text(subscription.price(on: .now), currencyCode: subscription.currencyCode, cycle: subscription.cycle)
        cycleText = CycleText.text(subscription.cycle)
        name = subscription.name
    }

    var displayRepresentation: DisplayRepresentation {
        // No price: Spotlight shows this to anyone searching the iPhone, and what you pay is private.
        DisplayRepresentation(title: "\(name)", subtitle: "\(cycleText)")
    }
}
