import Foundation

/// What a folder, or the whole inventory, holds: the one figure and the line under it.
nonisolated struct InventoryTotal: Equatable, Sendable {
    /// How many things: every item's quantity, added up. The figure of the screen.
    var quantity = 0
    /// How many different items.
    var itemCount = 0
    /// How many folders, at any depth.
    var folderCount = 0
    /// What the items with a price are worth; `nil` when none has one.
    var value: Decimal?
}
