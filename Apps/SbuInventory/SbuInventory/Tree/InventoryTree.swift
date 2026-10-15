import Foundation

/// The folders and items of the inventory as plain values: paths, totals, and where a folder may move.
///
/// Every walk up or down the tree is guarded against loops, so a damaged store or a bad import
/// can never hang the app.
nonisolated struct InventoryTree: Sendable {
    private let folders: [UUID: FolderNode]
    private let childrenByParent: [UUID?: [FolderNode]]
    private let itemsByFolder: [UUID?: [ItemNode]]

    init(folders: [FolderNode], items: [ItemNode]) {
        self.folders = Dictionary(folders.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        childrenByParent = Dictionary(grouping: folders, by: \.parentID)
        itemsByFolder = Dictionary(grouping: items, by: \.folderID)
    }

    /// The names from the top of the inventory down to the folder, the folder included; empty at the top.
    func path(of folderID: UUID?) -> [String] {
        var names: [String] = []
        var seen: Set<UUID> = []
        var current = folderID
        while let id = current, let folder = folders[id], seen.insert(id).inserted {
            names.append(folder.name)
            current = folder.parentID
        }
        return names.reversed()
    }

    /// The folder and every folder inside it, at any depth.
    func subtree(of folderID: UUID) -> Set<UUID> {
        var found: Set<UUID> = [folderID]
        var queue = [folderID]
        while let id = queue.popLast() {
            for child in childrenByParent[id] ?? [] where found.insert(child.id).inserted {
                queue.append(child.id)
            }
        }
        return found
    }

    /// What a folder holds at any depth, or the whole inventory when `folderID` is `nil`.
    func total(in folderID: UUID?) -> InventoryTotal {
        let scope: [UUID?]
        if let folderID {
            scope = subtree(of: folderID).map(Optional.some)
        } else {
            scope = [nil] + folders.keys.map(Optional.some)
        }
        var total = InventoryTotal()
        total.folderCount = scope.count - 1
        for id in scope {
            for item in itemsByFolder[id] ?? [] {
                let quantity = max(item.quantity, 0)
                total.quantity += quantity
                total.itemCount += 1
                if let price = item.unitPrice {
                    total.value = (total.value ?? 0) + price * Decimal(quantity)
                }
            }
        }
        return total
    }

    /// Every folder top down, each followed by the ones inside it, by name; with its depth, 0 at the top.
    func outline() -> [(folder: FolderNode, depth: Int)] {
        var result: [(folder: FolderNode, depth: Int)] = []
        var seen: Set<UUID> = []
        func visit(_ parentID: UUID?, depth: Int) {
            let children = (childrenByParent[parentID] ?? []).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            for child in children where seen.insert(child.id).inserted {
                result.append((child, depth))
                visit(child.id, depth: depth + 1)
            }
        }
        visit(nil, depth: 0)
        return result
    }

    /// Whether a folder can go into `target`: never into itself or into a folder inside it.
    func canMove(folder folderID: UUID, into target: UUID?) -> Bool {
        guard let target else { return true }
        return !subtree(of: folderID).contains(target)
    }
}
