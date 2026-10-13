import CloudKit
import Foundation
@testable import SbuHabits

/// The owner's shares, in memory: what `HabitSharing` reads and writes in tests.
actor FakeOutbox: SharedHabitsOutbox {
    private(set) var snapshots: [UUID: Data] = [:]
    private(set) var participants: [UUID: Int] = [:]
    private(set) var publishes = 0
    private(set) var stopped: [UUID] = []
    private var isAvailable: Bool
    private var isOffline = false

    init(isAvailable: Bool = true) {
        self.isAvailable = isAvailable
    }

    /// People join from their own iPhones.
    func setParticipants(_ count: Int, of habitID: UUID) {
        participants[habitID] = count
    }

    /// The owner stops sharing from another device: the zone goes.
    func dropShare(of habitID: UUID) {
        participants[habitID] = nil
        snapshots[habitID] = nil
    }

    func setOffline(_ offline: Bool) {
        isOffline = offline
    }

    func snapshot(of habitID: UUID) throws -> SharedHabitSnapshot? {
        try snapshots[habitID].map(SharedHabitSnapshot.decode)
    }

    func isAccountAvailable() async -> Bool {
        isAvailable
    }

    func sharedHabits() async throws -> [UUID: Int] {
        if isOffline { throw URLError(.notConnectedToInternet) }
        return participants
    }

    func prepareShare(of habitID: UUID, title: String, snapshot: Data) async throws -> CKShare {
        if isOffline { throw URLError(.notConnectedToInternet) }
        snapshots[habitID] = snapshot
        participants[habitID] = participants[habitID] ?? 0
        return CKShare(recordZoneID: CKRecordZone.ID(zoneName: "habit-\(habitID.uuidString)"))
    }

    func publish(_ snapshot: Data, of habitID: UUID) async throws {
        if isOffline { throw URLError(.notConnectedToInternet) }
        guard participants[habitID] != nil else { throw SharingFailure.notShared }
        snapshots[habitID] = snapshot
        publishes += 1
    }

    func stopSharing(_ habitID: UUID) async throws {
        participants[habitID] = nil
        snapshots[habitID] = nil
        stopped.append(habitID)
    }
}
