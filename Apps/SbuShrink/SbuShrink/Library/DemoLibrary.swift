import Foundation
import os

/// A library in memory for the UI tests, the screenshots and the previews: it saves nothing and
/// remembers what it was asked.
nonisolated final class DemoLibrary: VideoLibrary {
    private struct State {
        var access: LibraryAccess
        var saved: [URL] = []
        var deleted: [String] = []
    }

    private let state: OSAllocatedUnfairLock<State>

    init(access: LibraryAccess = .full) {
        state = OSAllocatedUnfairLock(initialState: State(access: access))
    }

    var saved: [URL] { state.withLock { $0.saved } }
    var deleted: [String] { state.withLock { $0.deleted } }

    func access() -> LibraryAccess {
        state.withLock { $0.access }
    }

    func requestAccess() async -> LibraryAccess {
        state.withLock { state in
            if state.access == .notDetermined {
                state.access = .full
            }
            return state.access
        }
    }

    func save(_ url: URL, original: String?, toAlbum: Bool) async throws -> String {
        try state.withLock { state in
            guard state.access.canSave else { throw LibraryError.denied }
            state.saved.append(url)
            return "saved-\(state.saved.count)"
        }
    }

    func delete(_ ids: [String]) async throws -> Int {
        state.withLock { state in
            state.deleted += ids
            return ids.count
        }
    }
}
