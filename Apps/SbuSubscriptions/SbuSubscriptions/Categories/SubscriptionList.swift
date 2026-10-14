import Foundation
import SwiftData

/// A list you group subscriptions into, such as Famiglia or Lavoro.
@Model
final class SubscriptionList {
    /// Stable across devices: the name of the list's CloudKit zone once it's shared.
    var uuid: UUID = UUID()
    var name: String = ""
    var order: Int = 0
    @Relationship(deleteRule: .nullify, inverse: \Subscription.list) var subscriptions: [Subscription]? = []

    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }
}
