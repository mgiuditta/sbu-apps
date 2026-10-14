import CloudKit
import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

/// Stands in for CloudKit on both sides, recording what the app sends.
final class FakeCloud: SharedListsOutbox, SharedListsInbox, @unchecked Sendable {
    // ponytail: @unchecked, the tests drive it from one task at a time.
    var shared: [UUID: Int] = [:]
    var publishedData: [UUID: [Data]] = [:]
    var stopped: [UUID] = []
    var gone: Set<UUID> = []
    var fetched: [FetchedShare] = []
    var left: [String] = []
    var subscribed = 0

    func isAccountAvailable() async -> Bool { true }
    func sharedLists() async throws -> [UUID: Int] { shared }
    func prepareShare(of listID: UUID, title: String, snapshot: Data) async throws -> CKShare {
        shared[listID] = 0
        publishedData[listID, default: []].append(snapshot)
        return CKShare(recordZoneID: CloudKitSharedLists.zoneID(of: listID))
    }
    func publish(_ snapshot: Data, of listID: UUID) async throws {
        if gone.contains(listID) { throw SharingFailure.notShared }
        publishedData[listID, default: []].append(snapshot)
    }
    func stopSharing(_ listID: UUID) async throws { stopped.append(listID) }
    func accept(_ metadata: CKShare.Metadata) async throws {}
    func fetchAll() async throws -> [FetchedShare] { fetched }
    func leave(_ key: String) async throws { left.append(key) }
    func subscribe() async throws { subscribed += 1 }
}

struct SharingTests {
    func item(_ name: String, _ price: Decimal = 10, status: SubscriptionStatus = .active, trialEnd: Date? = nil) -> SharedListSnapshot.Item {
        .init(name: name, price: price, currencyCode: "EUR", cycle: .monthly, startDate: .now.addingTimeInterval(-86_400 * 40), paymentCount: nil, trialEndDate: trialEnd, status: status)
    }

    @Test func snapshotCarriesOnlyWhatPeopleSee() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let family = SubscriptionList(name: "Famiglia", order: 0)
        context.insert(family)
        let video = Subscription(name: "Video", price: 13, currencyCode: "EUR", startDate: .now)
        video.notes = "password nel portachiavi"
        video.paymentMethod = "Carta personale"
        video.url = URL(string: "https://example.com")
        let music = Subscription(name: "Audio", price: 5, currencyCode: "USD", startDate: .now, cycle: .yearly)
        [video, music].forEach { context.insert($0); $0.list = family }

        let snapshot = SharedListSnapshot(list: family)
        #expect(snapshot.name == "Famiglia")
        #expect(snapshot.items.map(\.name) == ["Audio", "Video"])
        let json = String(decoding: try snapshot.encoded(), as: UTF8.self)
        #expect(!json.contains("portachiavi") && !json.contains("Carta") && !json.contains("example.com"), "Notes, payment method and site never travel")
        #expect(try SharedListSnapshot.decode(snapshot.encoded()) == snapshot)
    }

    @Test func newerSnapshotIsNotRead() throws {
        var snapshot = SharedListSnapshot(name: "A", items: [])
        snapshot.version = SharedListSnapshot.currentVersion + 1
        #expect(throws: (any Error).self) { try SharedListSnapshot.decode(snapshot.encoded()) }
    }

    @Test func receivedTotalFollowsTheOwnersRules() {
        let snapshot = SharedListSnapshot(name: "Famiglia", items: [
            item("Video", 10), item("Pausa", 20, status: .paused), item("Prova", 30, trialEnd: .now.addingTimeInterval(86_400 * 5)),
        ])
        let converter = CurrencyConverter(table: ExchangeRates(day: "", perEuro: ["EUR": 1]))
        let total = ReceivedListTotal.total(of: snapshot, per: .month, in: "EUR", converter: converter, on: .now)
        #expect(total.amount == 10)
    }

    @Test func mergeKeepsNamesDropsGoneHidesRemoved() {
        let a = SharedListSnapshot(name: "A", items: [])
        let a2 = SharedListSnapshot(name: "A nuova", items: [])
        var file = ReceivedListsFile()
        file.lists = [ReceivedList(key: "x|list-a", ownerName: "Anna", snapshot: a), ReceivedList(key: "x|list-gone", snapshot: a)]
        file.removed = ["x|list-removed"]
        let merged = ReceivedListsMerge.merge(file, with: [
            FetchedShare(key: "x|list-a", snapshot: a2),
            FetchedShare(key: "x|list-removed", snapshot: a),
            FetchedShare(key: "x|list-new", snapshot: a),
        ])
        #expect(merged.lists.map(\.key) == ["x|list-a", "x|list-new"])
        #expect(merged.lists.first?.ownerName == "Anna")
        #expect(merged.lists.first?.snapshot.name == "A nuova")
        #expect(merged.removed == ["x|list-removed"])
    }

    @Test func recipientRefreshesAndLeaves() async throws {
        let cloud = FakeCloud()
        cloud.fetched = [FetchedShare(key: "x|list-a", snapshot: SharedListSnapshot(name: "A", items: []))]
        let store = ReceivedListsStore(url: .temporaryDirectory.appending(path: "received-\(UUID().uuidString).json"))
        let received = ReceivedLists(store: store, inbox: cloud)
        await received.refresh()
        #expect(received.lists.map(\.key) == ["x|list-a"])
        #expect(cloud.subscribed == 1)

        await received.remove(try #require(received.lists.first))
        #expect(received.lists.isEmpty)
        #expect(cloud.left == ["x|list-a"])
    }

    @Test func ownerSendsOnlyChangesAndStopsForDeletedLists() async throws {
        let cloud = FakeCloud()
        let sharing = ListSharing(outbox: cloud)
        let kept = UUID(), deleted = UUID()
        cloud.shared = [kept: 2, deleted: 1]
        await sharing.refresh()
        let snapshot = SharedListSnapshot(name: "Famiglia", items: [item("Video")])

        await sharing.publish([kept: snapshot])
        await sharing.publish([kept: snapshot])
        #expect(cloud.publishedData[kept]?.count == 1, "An unchanged list is sent once")
        #expect(cloud.stopped == [deleted], "A list no longer in the store stops being shared")

        var changed = snapshot
        changed.items.append(item("Musica"))
        await sharing.publish([kept: changed])
        #expect(cloud.publishedData[kept]?.count == 2)
    }

    @Test func ownerForgetsAListUnsharedElsewhere() async {
        let cloud = FakeCloud()
        let sharing = ListSharing(outbox: cloud)
        let id = UUID()
        cloud.shared = [id: 1]
        cloud.gone = [id]
        await sharing.refresh()
        await sharing.publish([id: SharedListSnapshot(name: "A", items: [])])
        #expect(sharing.participants[id] == nil)
    }
}
