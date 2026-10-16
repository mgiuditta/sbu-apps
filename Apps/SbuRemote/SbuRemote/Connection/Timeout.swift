import Foundation

/// Runs `operation`, or throws `TVClientError.unreachable` when it takes longer than `limit`.
/// Pairing waits for the user to answer on the TV, so callers pass a long limit there.
func withTimeout<T: Sendable>(_ limit: Duration, _ operation: @escaping @Sendable @MainActor () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: limit)
            throw TVClientError.unreachable
        }
        defer { group.cancelAll() }
        guard let first = try await group.next() else { throw TVClientError.unreachable }
        return first
    }
}
