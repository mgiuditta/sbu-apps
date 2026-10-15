import Foundation

extension Item {
    /// The item as the tree's totals see it.
    var node: ItemNode {
        ItemNode(id: uuid, folderID: folder?.uuid, quantity: quantity, unitPrice: unitPrice)
    }

    /// At or below its minimum: "Da ricomprare".
    var isLow: Bool {
        LowStock.isLow(quantity: quantity, minimum: minimumQuantity)
    }

    /// Photos in the order you put them; the first is the one in lists.
    var sortedPhotos: [ItemPhoto] {
        (photos ?? []).sorted { $0.order < $1.order }
    }

    /// Price of one times the quantity; `nil` without a price.
    var totalValue: Decimal? {
        unitPrice.map { $0 * Decimal(max(quantity, 0)) }
    }

    /// Field values whose field still exists, in the order of the fields.
    var sortedFieldValues: [FieldValue] {
        (fieldValues ?? []).filter { $0.definition != nil }.sorted { ($0.definition?.order ?? 0) < ($1.definition?.order ?? 0) }
    }

    /// Rebuilds the search key from the name, notes, tags, label and custom field values.
    /// Call after every change to any of them.
    func refreshSearchKey() {
        let fieldTexts = (fieldValues ?? []).compactMap { value -> String? in
            if let text = value.text { return text }
            if let number = value.number { return "\(number)" }
            return nil
        }
        searchKey = SearchKey.make([name, notes, code ?? ""] + tags + fieldTexts)
    }
}
