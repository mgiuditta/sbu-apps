import CloudKit
import Foundation

/// The owner's side: one zone per shared list in the owner's own iCloud, shared whole, read only,
/// with the people the owner invites. CloudKit, or a fake in tests.
nonisolated protocol SharedListsOutbox: Sendable {
    func isAccountAvailable() async -> Bool
    /// Every list shared now, with how many people, the owner left out.
    func sharedLists() async throws -> [UUID: Int]
    /// The share of a list, made with its first snapshot if it is not shared yet.
    func prepareShare(of listID: UUID, title: String, snapshot: Data) async throws -> CKShare
    /// - Throws: `SharingFailure.notShared` once the list is no longer shared.
    func publish(_ snapshot: Data, of listID: UUID) async throws
    func stopSharing(_ listID: UUID) async throws
}

/// The side of whoever receives a shared list: the shares accepted, read from the shared database.
nonisolated protocol SharedListsInbox: Sendable {
    func accept(_ metadata: CKShare.Metadata) async throws
    func fetchAll() async throws -> [FetchedShare]
    func leave(_ key: String) async throws
    /// Asks iCloud for a silent notification whenever a shared list changes.
    func subscribe() async throws
}
