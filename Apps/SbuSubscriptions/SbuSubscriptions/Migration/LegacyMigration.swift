import Foundation
import SwiftData

/// Brings the 1.0's subscriptions into the store at first launch, silently (ADR-0010).
///
/// The 1.0's file is never changed or deleted. Each imported subscription keeps its 1.0 id, so running
/// again only adds what's missing. A row that can't be read is skipped and counted, never lost in silence:
/// Impostazioni shows how many and offers to try again.
enum LegacyMigration {
    struct Outcome: Equatable {
        var imported = 0
        var skipped = 0
        /// The file exists but couldn't be opened or read.
        var unreadable = false
    }

    enum Key {
        static let done = "legacyMigration.done"
        static let skipped = "legacyMigration.skipped"
        static let unreadable = "legacyMigration.unreadable"
    }

    /// Runs once; after a full success it never runs again on its own.
    @discardableResult
    static func runIfNeeded(_ context: ModelContext, documents: URL = .documentsDirectory, defaults: UserDefaults = .appGroup, currency: CurrencySettings? = nil, calendar: Calendar = .current) -> Outcome? {
        guard !defaults.bool(forKey: Key.done) else { return nil }
        return run(context, documents: documents, defaults: defaults, currency: currency, calendar: calendar)
    }

    @discardableResult
    static func run(_ context: ModelContext, documents: URL = .documentsDirectory, defaults: UserDefaults = .appGroup, currency: CurrencySettings? = nil, calendar: Calendar = .current) -> Outcome {
        let url = LegacyDatabase.url(in: documents)
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            // A new install: nothing to bring over, ever.
            defaults.set(true, forKey: Key.done)
            return Outcome()
        }
        var outcome = Outcome()
        do {
            let rows = try LegacyDatabase.rows(at: url)
            let existing = Set(((try? context.fetch(FetchDescriptor<Subscription>())) ?? []).compactMap(\.legacyID))
            var categories = (try? context.fetch(FetchDescriptor<SubscriptionCategory>())) ?? []
            let serviceIDs = Set(CatalogService.bundled.map(\.id))
            var currencies: [String: Int] = [:]
            for row in rows where !existing.contains(row.id) {
                guard let legacy = try? LegacyConversion.convert(row, serviceIDs: serviceIDs, calendar: calendar) else {
                    outcome.skipped += 1
                    continue
                }
                context.insert(subscription(from: legacy, categories: &categories, context: context))
                currencies[legacy.currencyCode, default: 0] += 1
                outcome.imported += 1
            }
            try context.save()
            if let currency, let mostUsed = currencies.max(by: { $0.value < $1.value })?.key, !currency.hasChosenMainCurrency {
                currency.mainCurrency = mostUsed
            }
        } catch {
            outcome.unreadable = true
        }
        defaults.set(outcome.skipped, forKey: Key.skipped)
        defaults.set(outcome.unreadable, forKey: Key.unreadable)
        defaults.set(outcome.skipped == 0 && !outcome.unreadable, forKey: Key.done)
        return outcome
    }

    private static func subscription(from legacy: LegacySubscription, categories: inout [SubscriptionCategory], context: ModelContext) -> Subscription {
        let subscription = Subscription(name: legacy.name, price: legacy.price, currencyCode: legacy.currencyCode, startDate: legacy.startDate, cycle: legacy.cycle)
        subscription.legacyID = legacy.legacyID
        subscription.trialEndDate = legacy.trialEndDate
        subscription.reminderDaysBefore = legacy.reminderDaysBefore
        subscription.serviceID = legacy.serviceID
        subscription.notes = legacy.notes
        subscription.createdAt = legacy.createdAt
        if let key = legacy.category?.rawValue {
            subscription.category = categories.first { $0.key == key }
        } else if let name = legacy.customCategory {
            if let match = categories.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
                subscription.category = match
            } else {
                let category = SubscriptionCategory(customName: name, symbol: BuiltInCategory.other.symbol, order: (categories.map(\.order).max() ?? 0) + 1)
                context.insert(category)
                categories.append(category)
                subscription.category = category
            }
        }
        return subscription
    }
}
