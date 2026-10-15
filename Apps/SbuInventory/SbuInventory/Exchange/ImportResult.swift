/// What an import did, for the message after it.
nonisolated struct ImportResult: Equatable, Sendable {
    /// Items added.
    var added = 0
    /// Items already in the inventory, left as they are.
    var skipped = 0
    /// Folders created.
    var folders = 0
}
