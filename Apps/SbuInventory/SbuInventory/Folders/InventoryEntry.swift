import Foundation

/// An item or a folder: what "Sposta in" moves or "Elimina" deletes.
enum InventoryEntry: Identifiable {
    case item(Item)
    case folder(Folder)

    var id: UUID {
        switch self {
        case let .item(item): item.uuid
        case let .folder(folder): folder.uuid
        }
    }

    var name: String {
        switch self {
        case let .item(item): item.name
        case let .folder(folder): folder.name
        }
    }

    /// Where it is now; `nil` at the top.
    var currentFolder: Folder? {
        switch self {
        case let .item(item): item.folder
        case let .folder(folder): folder.parent
        }
    }
}
