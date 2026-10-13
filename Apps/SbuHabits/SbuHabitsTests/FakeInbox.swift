import CloudKit
import Foundation
@testable import SbuHabits

/// The shares joined, in memory: what `ReceivedHabits` reads in tests.
actor FakeInbox: SharedHabitsInbox {
    /// Every share listed, in order; `nil` for one whose record cannot be read.
    private(set) var shares: [(key: String, snapshot: SharedHabitSnapshot?)] = []
    private(set) var left: [String] = []
    private(set) var subscriptions = 0
    private var isOffline = false
    private var failsToLeave = false

    func put(_ key: String, _ snapshot: SharedHabitSnapshot?) {
        if let index = shares.firstIndex(where: { $0.key == key }) {
            shares[index].snapshot = snapshot
        } else {
            shares.append((key, snapshot))
        }
    }

    /// The owner stops sharing, or deletes the habit.
    func drop(_ key: String) {
        shares.removeAll { $0.key == key }
    }

    func setOffline(_ offline: Bool) {
        isOffline = offline
    }

    func setFailsToLeave(_ fails: Bool) {
        failsToLeave = fails
    }

    func accept(_ metadata: CKShare.Metadata) async throws {}

    func fetchAll() async throws -> [FetchedShare] {
        if isOffline { throw URLError(.notConnectedToInternet) }
        return shares.map { FetchedShare(key: $0.key, snapshot: $0.snapshot) }
    }

    func leave(_ key: String) async throws {
        if failsToLeave || isOffline { throw URLError(.notConnectedToInternet) }
        left.append(key)
        drop(key)
    }

    func subscribe() async throws {
        if isOffline { throw URLError(.notConnectedToInternet) }
        subscriptions += 1
    }
}
