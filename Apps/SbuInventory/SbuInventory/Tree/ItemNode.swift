import Foundation

/// An item as the totals see it: where it is, how many, what one costs.
nonisolated struct ItemNode: Hashable, Sendable {
    let id: UUID
    /// `nil` at the top of the inventory.
    let folderID: UUID?
    let quantity: Int
    var unitPrice: Decimal?
}
