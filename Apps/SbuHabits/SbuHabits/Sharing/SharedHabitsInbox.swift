import CloudKit
import Foundation

/// The side of whoever receives an Abitudine condivisa: the shares accepted, read from iCloud's
/// shared database. CloudKit, or a fake in tests.
nonisolated protocol SharedHabitsInbox: Sendable {
    /// Joins a share the user opened from an invitation.
    func accept(_ metadata: CKShare.Metadata) async throws

    /// Every share this user has joined, each with its snapshot when it can be read.
    func fetchAll() async throws -> [FetchedShare]

    /// Leaves a share: its owner keeps it, this user stops seeing it.
    func leave(_ key: String) async throws

    /// Asks iCloud for a silent notification whenever a shared habit changes.
    func subscribe() async throws
}
