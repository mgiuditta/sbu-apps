import Foundation

/// The dictionaries WatchConnectivity carries between the iPhone and the Apple Watch: JSON of a
/// `WatchSnapshot` or a `WatchAction` under one key, or a request for a fresh grid.
nonisolated enum WatchPayload {
    private static let snapshotKey = "snapshot"
    private static let actionKey = "action"
    private static let refreshKey = "refresh"

    /// The application context the iPhone sends: always the latest grid, replacing the one before.
    static func context(for snapshot: WatchSnapshot) throws -> [String: Any] {
        [snapshotKey: try JSONEncoder().encode(snapshot)]
    }

    static func snapshot(from payload: [String: Any]) -> WatchSnapshot? {
        guard let data = payload[snapshotKey] as? Data else { return nil }
        return try? JSONDecoder().decode(WatchSnapshot.self, from: data)
    }

    /// The user info the watch queues: delivered once, in order, when the iPhone is reachable.
    static func userInfo(for action: WatchAction) throws -> [String: Any] {
        [actionKey: try JSONEncoder().encode(action)]
    }

    static func action(from payload: [String: Any]) -> WatchAction? {
        guard let data = payload[actionKey] as? Data else { return nil }
        return try? JSONDecoder().decode(WatchAction.self, from: data)
    }

    /// The message the watch sends when its grid is from a day gone by.
    static var refreshRequest: [String: Any] { [refreshKey: true] }

    static func isRefreshRequest(_ payload: [String: Any]) -> Bool {
        payload[refreshKey] as? Bool == true
    }
}
