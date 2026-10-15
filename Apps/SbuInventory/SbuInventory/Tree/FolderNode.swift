import Foundation

/// A folder as the tree sees it: who it is, what it is called, where it is.
nonisolated struct FolderNode: Hashable, Sendable {
    let id: UUID
    let name: String
    /// `nil` at the top of the inventory.
    let parentID: UUID?
}
