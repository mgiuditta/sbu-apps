import CloudKit
import Foundation
import Observation

/// The owner's shared lists: which are shared and with how many people, and the snapshot each shows,
/// sent again after a save that changes it. Deleting a shared list stops sharing it. Independent from
/// Sincronizza con iCloud: it needs iCloud, not the switch.
@Observable
final class ListSharing {
    /// iCloud is signed in: without it Condividi is off and says why.
    private(set) var isAvailable: Bool
    private(set) var participants: [UUID: Int] = [:]

    @ObservationIgnored private let outbox: (any SharedListsOutbox)?
    /// The last snapshot sent of each list, so an unchanged one is not sent again.
    @ObservationIgnored private var published: [UUID: SharedListSnapshot] = [:]
    @ObservationIgnored private var isPublishing = false
    @ObservationIgnored private var pendingSnapshots: [UUID: SharedListSnapshot]?

    /// - Parameter outbox: CloudKit, a fake in tests; `nil` never shares, for UI tests and previews.
    init(outbox: (any SharedListsOutbox)?) {
        self.outbox = outbox
        isAvailable = false
    }

    static func live() -> ListSharing {
        let defaults = UserDefaults.standard
        let isTest = defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE")
        return ListSharing(outbox: isTest ? nil : CloudKitSharedLists())
    }

    func isShared(_ list: SubscriptionList) -> Bool {
        participants[list.uuid] != nil
    }

    /// At launch and whenever the app comes back: the account and the shares.
    func refresh() async {
        guard let outbox else { return }
        isAvailable = await outbox.isAccountAvailable()
        guard isAvailable, let shared = try? await outbox.sharedLists() else { return }
        participants = shared
        published = published.filter { shared[$0.key] != nil }
    }

    func prepareShare(of list: SubscriptionList) async throws -> CKShare {
        guard let outbox, isAvailable else { throw SharingFailure.unavailable }
        let snapshot = SharedListSnapshot(list: list)
        let share = try await outbox.prepareShare(of: list.uuid, title: list.name, snapshot: try snapshot.encoded())
        published[list.uuid] = snapshot
        participants[list.uuid] = participants[list.uuid] ?? 0
        return share
    }

    /// After the system sharing screen: people invited or removed, or sharing stopped.
    func sharingDidChange(for listID: UUID, stopped: Bool) async {
        guard let outbox else { return }
        if stopped {
            participants[listID] = nil
            published[listID] = nil
            try? await outbox.stopSharing(listID)
        }
        await refresh()
    }

    /// Sends every shared list whose snapshot changed, and stops sharing the ones no longer in the store.
    /// - Parameter snapshots: every list in the store now, by id.
    func publish(_ snapshots: [UUID: SharedListSnapshot]) async {
        guard let outbox, isAvailable, !participants.isEmpty else { return }
        guard !isPublishing else {
            pendingSnapshots = snapshots
            return
        }
        isPublishing = true
        var next: [UUID: SharedListSnapshot]? = snapshots
        while let current = next {
            pendingSnapshots = nil
            await pass(current, with: outbox)
            next = pendingSnapshots
        }
        isPublishing = false
    }

    private func pass(_ snapshots: [UUID: SharedListSnapshot], with outbox: any SharedListsOutbox) async {
        for listID in participants.keys.sorted(by: { $0.uuidString < $1.uuidString }) {
            guard let snapshot = snapshots[listID] else {
                participants[listID] = nil
                published[listID] = nil
                try? await outbox.stopSharing(listID)
                continue
            }
            guard published[listID] != snapshot, let data = try? snapshot.encoded() else { continue }
            do {
                try await outbox.publish(data, of: listID)
                published[listID] = snapshot
            } catch SharingFailure.notShared {
                participants[listID] = nil
                published[listID] = nil
            } catch {
                // Offline or iCloud busy: the next save or the next time the app comes back sends it.
            }
        }
    }
}
