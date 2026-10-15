import Foundation

/// What the search shows: items whose key holds every word, with every chosen tag, only the low ones
/// when asked, and only inside the folder you search from.
nonisolated struct ItemFilter: Sendable {
    var query = SearchQuery("")
    var tags: [String] = []
    var onlyLow = false
    /// The folders searched, at any depth; `nil` for the whole inventory.
    var folders: Set<UUID>?

    /// Whether anything narrows the list, so the screen shows results instead of folders.
    var isActive: Bool {
        !query.isEmpty || !tags.isEmpty || onlyLow
    }

    func matches(key: String, tags itemTags: [String], isLow: Bool, folderID: UUID?) -> Bool {
        if let folders {
            guard let folderID, folders.contains(folderID) else { return false }
        }
        if onlyLow, !isLow { return false }
        let folded = Set(itemTags.map(SearchKey.fold))
        guard tags.allSatisfy({ folded.contains(SearchKey.fold($0)) }) else { return false }
        return query.matches(key)
    }
}
