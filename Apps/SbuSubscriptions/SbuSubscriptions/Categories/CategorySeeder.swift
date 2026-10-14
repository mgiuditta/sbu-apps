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
}
