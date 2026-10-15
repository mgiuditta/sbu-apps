import Foundation
import SwiftData

/// Every change to folders and items the screens make, saved at once so nothing waits on autosave.
enum InventoryActions {
    @discardableResult
    static func createFolder(named name: String, in parent: Folder?, context: ModelContext) -> Folder? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        let folder = Folder(name: name, parent: parent)
        context.insert(folder)
        save(context)
        return folder
    }

    static func rename(_ folder: Folder, to name: String, context: ModelContext) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        folder.name = name
        save(context)
    }

    static func move(_ item: Item, to folder: Folder?, context: ModelContext) {
        item.folder = folder
        item.updatedAt = .now
        save(context)
    }

    /// Moves a folder, unless `target` is the folder itself or inside it.
    static func move(_ folder: Folder, to target: Folder?, context: ModelContext) {
        let folders = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        let tree = InventoryTree(folders: folders.map(\.node), items: [])
        guard tree.canMove(folder: folder.uuid, into: target?.uuid) else { return }
        folder.parent = target
        save(context)
    }

    static func setQuantity(_ quantity: Int, of item: Item, context: ModelContext) {
        item.quantity = max(quantity, 0)
        item.updatedAt = .now
        save(context)
    }

    static func delete(_ item: Item, context: ModelContext) {
        context.delete(item)
        save(context)
    }

    /// Deletes the folder with every folder and item inside it.
    static func delete(_ folder: Folder, context: ModelContext) {
        context.delete(folder)
        save(context)
    }

    static func save(_ context: ModelContext) {
        try? context.save()
    }
}
