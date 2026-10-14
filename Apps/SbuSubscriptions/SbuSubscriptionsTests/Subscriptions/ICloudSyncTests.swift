import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct ICloudSyncTests {
    @Test func modelIsCloudKitCompatible() throws {
        // SwiftData refuses, when it opens the store, a model CloudKit can't mirror (a unique attribute,
        // a non-optional relationship, a property without a default).
        let url = URL.temporaryDirectory.appending(path: "cloud-\(UUID().uuidString).store")
        let schema = Schema(versionedSchema: SubscriptionsSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .private(ModelContainer.subscriptionsCloudContainer))
        _ = try ModelContainer(for: schema, configurations: configuration)
    }

    @Test func duplicateBuiltInCategoriesAreMerged() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        // What a second device's seeding looks like once it synced in.
        let copy = SubscriptionCategory(key: "music", symbol: "music.note", order: 99)
        context.insert(copy)
        let spotify = Subscription(name: "Spotify", price: 10, currencyCode: "EUR", startDate: .now)
        context.insert(spotify)
        spotify.category = copy
        try context.save()

        try CategorySeeder.mergeDuplicates(context)
        let music = try context.fetch(FetchDescriptor<SubscriptionCategory>()).filter { $0.key == "music" }
        #expect(music.count == 1)
        #expect(spotify.category?.key == "music")
        #expect(spotify.category?.order != 99, "The original is kept, the copy goes")
    }
}
