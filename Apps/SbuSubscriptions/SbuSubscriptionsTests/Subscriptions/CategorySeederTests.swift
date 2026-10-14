import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct CategorySeederTests {
    @Test func newStoreGetsEveryBuiltInCategoryOnce() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        try CategorySeeder.seed(context)
        let categories = try context.fetch(FetchDescriptor<SubscriptionCategory>())
        #expect(categories.count == BuiltInCategory.allCases.count)
    }

    @Test func renamedCategoryIsNotAddedAgain() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        let music = try #require(try context.fetch(FetchDescriptor<SubscriptionCategory>()).first { $0.key == "music" })
        music.customName = "Spotify e simili"
        try CategorySeeder.seed(context)
        let all = try context.fetch(FetchDescriptor<SubscriptionCategory>())
        #expect(all.count { $0.key == "music" } == 1)
        #expect(music.name == "Spotify e simili")
    }

    @Test func deletingACategoryKeepsItsSubscriptions() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let category = SubscriptionCategory(customName: "Casa", symbol: "house", order: 0)
        let subscription = Subscription(name: "Luce", price: 40, currencyCode: "EUR", startDate: .now)
        subscription.category = category
        context.insert(subscription)
        try context.save()
        context.delete(category)
        try context.save()
        #expect(try context.fetch(FetchDescriptor<Subscription>()).first?.category == nil)
    }

    @Test(arguments: [("Musica", BuiltInCategory.music), ("Produttività", .productivity), ("Gaming", .gaming)])
    func legacyLabelsMatch(label: String, expected: BuiltInCategory) {
        #expect(BuiltInCategory(legacyLabel: label) == expected)
    }
}
