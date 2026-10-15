/// Whether a line of the inventory file is an item or a folder.
nonisolated enum InventoryRowKind: String, Sendable {
    case item = "oggetto"
    case folder = "cartella"

    /// Reads the type column, in Italian or English; anything else is an item.
    init(text: String) {
        switch SearchKey.fold(text) {
        case "cartella", "folder", "luogo", "location": self = .folder
        default: self = .item
        }
    }
}
