import Foundation

extension Folder {
    /// The folder as the tree sees it.
    var node: FolderNode {
        FolderNode(id: uuid, name: name, parentID: parent?.uuid)
    }

    /// The folders inside, by name.
    var sortedChildren: [Folder] {
        (children ?? []).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// The items directly inside, by name.
    var sortedItems: [Item] {
        (items ?? []).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
