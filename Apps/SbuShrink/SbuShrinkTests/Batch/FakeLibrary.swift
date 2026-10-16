import Foundation
import os
@testable import SbuShrink

/// A library whose permission, saves and deletions the test decides, recording every call.
nonisolated final class FakeLibrary: VideoLibrary {
    struct Calls {
        var requests = 0
        var saved: [(url: URL, original: String?, toAlbum: Bool)] = []
        var deleted: [String] = []
    }

    private let state: OSAllocatedUnfairLock<(access: LibraryAccess, calls: Calls)>
    private let granted: LibraryAccess
    private let failsSave: Bool
    private let deleteError: LibraryError?
    private let deletes: Int?

    /// - Parameters:
    ///   - granted: What the permission becomes when asked.
    ///   - deletes: How many deletions it reports; all asked when `nil`.
    init(access: LibraryAccess = .full, granted: LibraryAccess = .full, failsSave: Bool = false, deleteError: LibraryError? = nil, deletes: Int? = nil) {
        state = OSAllocatedUnfairLock(initialState: (access, Calls()))
        self.granted = granted
        self.failsSave = failsSave
        self.deleteError = deleteError
        self.deletes = deletes
    }

    var calls: Calls { state.withLock { $0.calls } }

    func access() -> LibraryAccess {
        state.withLock { $0.access }
    }

    func requestAccess() async -> LibraryAccess {
        state.withLock { state in
            state.calls.requests += 1
            if state.access == .notDetermined { state.access = granted }
            return state.access
        }
    }

    func save(_ url: URL, original: String?, toAlbum: Bool) async throws -> String {
        if failsSave { throw LibraryError.saveFailed }
        return state.withLock { state in
            state.calls.saved.append((url, original, toAlbum))
            return "new/\(state.calls.saved.count)"
        }
    }

    func delete(_ ids: [String]) async throws -> Int {
        if let deleteError { throw deleteError }
        state.withLock { $0.calls.deleted += ids }
        return deletes ?? ids.count
    }
}
