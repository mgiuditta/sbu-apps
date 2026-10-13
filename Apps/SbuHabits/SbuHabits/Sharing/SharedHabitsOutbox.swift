import CloudKit
import Foundation

/// The owner's side of the Abitudini condivise: one zone per shared habit in the owner's own
/// iCloud, shared whole with the people the owner invites. CloudKit, or a fake in tests.
nonisolated protocol SharedHabitsOutbox: Sendable {
    /// iCloud is signed in: sharing needs it, Sincronizza con iCloud does not.
    func isAccountAvailable() async -> Bool

    /// Every habit shared now, with how many people it is shared with, the owner left out.
    func sharedHabits() async throws -> [UUID: Int]

    /// The share of a habit, made with its first snapshot if it is not shared yet: what the
    /// system sharing screen invites people to and lists them from.
    func prepareShare(of habitID: UUID, title: String, snapshot: Data) async throws -> CKShare

    /// Replaces the snapshot people see.
    /// - Throws: `SharingFailure.notShared` once the habit is no longer shared.
    func publish(_ snapshot: Data, of habitID: UUID) async throws

    /// Deletes the habit's zone, its snapshot and its share: people lose it at their next refresh.
    func stopSharing(_ habitID: UUID) async throws
}
