import Foundation

/// One line of the inventory file: an item, or a folder that has to exist even when empty.
nonisolated struct InventoryRow: Equatable, Sendable {
    var kind = InventoryRowKind.item
    /// The item's id; an import skips the items it already has.
    var id: UUID?
    var name = ""
    var quantity = 1
    var minimumQuantity: Int?
    /// Folder names from the top down: for an item where it is, for a folder where it sits.
    var path: [String] = []
    var unitPrice: Decimal?
    /// ISO 4217 code the price was written in.
    var currency: String?
    var purchaseDate: Date?
    var tags: [String] = []
    var code: String?
    var notes = ""
    /// Paths of the photos inside the archive, such as `photos/…heic`.
    var photos: [String] = []
    /// Custom field values in their file form, by field.
    var fields: [CustomFieldCell] = []
}
