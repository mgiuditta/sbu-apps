import CloudKit
import Foundation
import Observation

/// The lists other people share with you: read only, in a file of their own, refreshed when the app
/// comes back and when iCloud says one changed. Never in your total, your reminders or your widget.
@Observable
final class ReceivedLists {
    private(set) var lists: [ReceivedList] = []

    @ObservationIgnored private let store: ReceivedListsStore
    @ObservationIgnored private let inbox: (any SharedListsInbox)?
    @ObservationIgnored private let preferences: UserDefaults?
    /// The file could not be read: nothing is written, so it is never lost.
    @ObservationIgnored private var isUnreadable = false

    private static let subscribedKey = "subscribedToSharedLists"

    /// - Parameters:
    ///   - inbox: CloudKit, a fake in tests; `nil` never reaches iCloud, for UI tests and previews.
    ///   - preferences: where the iCloud subscription is remembered; `nil` subscribes at every refresh.
    init(store: ReceivedListsStore, inbox: (any SharedListsInbox)?, preferences: UserDefaults? = nil) {
        self.store = store
        self.inbox = inbox
        self.preferences = preferences
        reload()
    }

    static func live() -> ReceivedLists {
        let defaults = UserDefaults.standard
        let isTest = defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE")
        let store = ReceivedListsStore.shared
        // UI tests only: one made-up list someone shares, to check the screens without a second Apple ID.
        if defaults.bool(forKey: "SBU_DEMO_RECEIVED") {
            try? store.save(ReceivedListsFile(lists: [ReceivedList(key: "demo|list-demo", ownerName: "Anna Rossi", snapshot: .demo)]))
        }
        return ReceivedLists(store: store, inbox: isTest ? nil : CloudKitSharedLists(), preferences: isTest ? nil : .appGroup)
    }

    func reload() {
        do {
            lists = try store.load().lists
            isUnreadable = false
        } catch {
            lists = []
            isUnreadable = true
        }
    }

    /// Joins a share opened from an invitation, then shows it with its owner's name.
    func accept(_ metadata: CKShare.Metadata) async {
        // The owner opening their own link: it is already theirs.
        guard let inbox, metadata.participantRole != .owner else { return }
        try? await inbox.accept(metadata)
        let owner = metadata.ownerIdentity.nameComponents?.formatted()
        await refresh()
        if let owner, var file = try? store.load(),
           let index = file.lists.firstIndex(where: { CloudKitSharedLists.zoneID(fromKey: $0.key)?.zoneName == metadata.share.recordID.zoneID.zoneName }) {
            file.lists[index].ownerName = owner
            save(file)
        }
    }

    /// Reads every share from iCloud and takes the changes; leaves the shares the user removed.
    func refresh() async {
        guard let inbox, !isUnreadable else { return }
        await subscribeIfNeeded(with: inbox)
        for key in (try? store.load().removed) ?? [] {
            try? await inbox.leave(key)
        }
        guard let fetched = try? await inbox.fetchAll(), let file = try? store.load() else { return }
        save(ReceivedListsMerge.merge(file, with: fetched))
    }

    /// Takes the list off this iPhone and leaves its share; until iCloud confirms, it stays hidden.
    func remove(_ received: ReceivedList) async {
        guard var file = try? store.load() else { return }
        file.lists.removeAll { $0.key == received.key }
        file.removed.insert(received.key)
        save(file)
        guard let inbox else { return }
        do {
            try await inbox.leave(received.key)
            guard var file = try? store.load() else { return }
            file.removed.remove(received.key)
            save(file)
        } catch {
            // Left again at the next refresh.
        }
    }

    private func save(_ file: ReceivedListsFile) {
        guard !isUnreadable else { return }
        // ponytail: a failed write keeps the change in memory only; the next refresh writes again.
        try? store.save(file)
        lists = file.lists
    }

    private func subscribeIfNeeded(with inbox: any SharedListsInbox) async {
        guard preferences?.bool(forKey: Self.subscribedKey) != true else { return }
        do {
            try await inbox.subscribe()
            preferences?.set(true, forKey: Self.subscribedKey)
        } catch {
            // Tried again at the next refresh.
        }
    }
}
