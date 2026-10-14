import Foundation
import SwiftData

/// A category you file subscriptions under, shown as its SF Symbol on every row.
@Model
final class SubscriptionCategory {
    /// The built-in category it started as, kept when you rename it; `nil` for one you made.
    var key: String?
    /// Your name for it; empty keeps the built-in name in the current language.
    var customName: String = ""
    var symbol: String = BuiltInCategory.other.symbol
    var order: Int = 0
    @Relationship(deleteRule: .nullify, inverse: \Subscription.category) var subscriptions: [Subscription]? = []

    init(key: String? = nil, customName: String = "", symbol: String, order: Int) {
        self.key = key
        self.customName = customName
        self.symbol = symbol
        self.order = order
    }

    var name: String {
        if !customName.isEmpty { return customName }
        return key.flatMap(BuiltInCategory.init(rawValue:))?.name ?? customName
    }
}
