import Foundation
import SwiftData

/// A list you group subscriptions into, such as Famiglia or Lavoro.
@Model
final class SubscriptionList {
    var name: String = ""
    var order: Int = 0
    @Relationship(deleteRule: .nullify, inverse: \Subscription.list) var subscriptions: [Subscription]? = []

    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }
}
