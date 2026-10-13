import Foundation

/// Where Sincronizza con iCloud keeps the shared copy of the habits: the iCloud container, or a
/// fake in tests.
nonisolated protocol HabitsRemote: Sendable {
    func read() async throws -> RemoteRead

    /// Replaces the copy with `data`, then marks `conflicts` resolved: they are merged into it.
    func write(_ data: Data, resolving conflicts: [RemoteConflict]) async throws
}
