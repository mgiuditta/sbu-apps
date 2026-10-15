import Foundation
import SwiftData

/// One thing you own: what it is, where it is, how many.
///
/// Every property has a default and every relationship is optional, so the store can sync
/// through the user's iCloud (ADR-0008) without a migration.
@Model
final class Item {
    /// Stable across launches, exports and devices: an import skips the items it already has.
    var uuid: UUID = UUID()
    var name: String = ""
    /// Name, notes, tags, label and field values folded for search; see `SearchKey`.
    var searchKey: String = ""
    var quantity: Int = 1
    /// At or below this the item is "Da ricomprare"; `nil` for no minimum.
    var minimumQuantity: Int?
    /// Price of one, in the currency of the device's region.
    var unitPrice: Decimal?
    var purchaseDate: Date?
    var notes: String = ""
    var tags: [String] = []
    /// The barcode or QR code already on the item, to find it by scanning.
    var code: String?
    /// The folder it is in; `nil` at the top of the inventory.
    var folder: Folder?
    @Relationship(deleteRule: .cascade, inverse: \ItemPhoto.item)
    var photos: [ItemPhoto]? = []
    @Relationship(deleteRule: .cascade, inverse: \FieldValue.item)
    var fieldValues: [FieldValue]? = []
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    init(name: String, quantity: Int = 1, folder: Folder? = nil) {
        self.name = name
        self.quantity = quantity
        self.folder = folder
    }
}
