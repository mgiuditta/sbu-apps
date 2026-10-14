import AppIntents
import CoreSpotlight

@available(iOS 18, *)
extension SubscriptionEntity: IndexedEntity {}

/// Keeps the subscriptions in Spotlight on iOS 18 and later; on iOS 17 Siri and Shortcuts still find them by name.
enum SpotlightIndex {
    static func update(_ subscriptions: [Subscription]) {
        SubscriptionsShortcuts.updateAppShortcutParameters()
        guard #available(iOS 18, *) else { return }
        let entities = subscriptions.map(SubscriptionEntity.init)
        Task {
            let index = CSSearchableIndex.default()
            try? await index.deleteAppEntities(ofType: SubscriptionEntity.self)
            try? await index.indexAppEntities(entities)
        }
    }
}
