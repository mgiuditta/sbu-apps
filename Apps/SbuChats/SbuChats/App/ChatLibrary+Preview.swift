import Foundation

extension ChatLibrary {
    /// An empty in-memory library for previews; `.task { await library.importSample() }` fills it.
    static var preview: ChatLibrary {
        // An in-memory store only fails if SQLite itself is missing.
        // swiftlint:disable:next force_try
        let store = try! ChatStore(url: nil)
        return ChatLibrary(store: store, knownOwners: KnownOwners(defaults: UserDefaults(suiteName: "preview") ?? .standard))
    }
}
