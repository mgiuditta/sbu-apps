import Foundation

/// Reads and writes the Apple Watch's `WatchState` as JSON, in the App Group on the watch so the
/// complication reads the same grid. The iPhone never uses it: its file is `HabitsStore`.
nonisolated struct WatchStateStore: Sendable {
    /// The file in the watch's App Group container, or in Application Support if the group is missing.
    static var shared: WatchStateStore {
        let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: HabitsStore.appGroup) ?? .applicationSupportDirectory
        return WatchStateStore(url: folder.appending(path: "watch.json"))
    }

    let url: URL

    /// The saved state, or an empty one when nothing came from the iPhone yet or it cannot be read:
    /// the next grid from the iPhone replaces it anyway.
    func load() -> WatchState {
        guard let data = try? Data(contentsOf: url), let state = try? JSONDecoder().decode(WatchState.self, from: data) else {
            return WatchState()
        }
        return state
    }

    func save(_ state: WatchState) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(state).write(to: url, options: .atomic)
    }
}
