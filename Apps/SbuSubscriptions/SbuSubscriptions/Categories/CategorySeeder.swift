import Foundation
import SwiftData

/// Adds the built-in categories a store is missing, so a new store starts with all of them and a newer
/// version can add one. Matched by key, so a renamed category is never added twice.
enum CategorySeeder {
    static func seed(_ context: ModelContext) throws {
        let existing = Set(try context.fetch(FetchDescriptor<SubscriptionCategory>()).compactMap(\.key))
        for (order, category) in BuiltInCategory.allCases.enumerated() where !existing.contains(category.rawValue) {
            context.insert(SubscriptionCategory(key: category.rawValue, symbol: category.symbol, order: order))
        }
        try context.save()
    }

    /// Two devices that synced through iCloud each seeded the same built-in categories: keep the oldest
    /// of each key, move its subscriptions over, delete the copies.
    static func mergeDuplicates(_ context: ModelContext) throws {
        let categories = try context.fetch(FetchDescriptor<SubscriptionCategory>(sortBy: [SortDescriptor(\.order)]))
        var kept: [String: SubscriptionCategory] = [:]
        var changed = false
        for category in categories {
            guard let key = category.key else { continue }
            guard let original = kept[key] else {
                kept[key] = category
                continue
            }
            for subscription in category.subscriptions ?? [] { subscription.category = original }
            if original.customName.isEmpty { original.customName = category.customName }
            context.delete(category)
            changed = true
        }
        if changed { try context.save() }
    }
}
