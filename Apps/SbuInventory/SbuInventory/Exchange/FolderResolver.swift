import Foundation
import SwiftData

/// Finds the folder at a path of names, creating the missing ones along the way.
/// Names match ignoring case and accents, so "garage" in a file lands in your "Garage".
struct FolderResolver {
    private let context: ModelContext
    private var byParentAndName: [String: Folder] = [:]
    /// How many folders it made.
    private(set) var created = 0

    init(context: ModelContext) {
        self.context = context
        for folder in (try? context.fetch(FetchDescriptor<Folder>())) ?? [] {
            byParentAndName[Self.key(parent: folder.parent, name: folder.name)] = folder
        }
    }

    /// The longest folder name an import keeps.
    static let maxNameLength = 200

    /// The folder at `path`, top first; `nil` for an empty path, the top of the inventory.
    /// A path deeper than `InventoryTree.maxDepth` is cut there, and a very long name is shortened,
    /// so a malformed file can't build a tree the app can't show.
    mutating func folder(at path: [String]) -> Folder? {
        var parent: Folder?
        let names = path.lazy
            .map { String($0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.maxNameLength)) }
            .filter { !$0.isEmpty }
            .prefix(InventoryTree.maxDepth)
        for name in names {
            let key = Self.key(parent: parent, name: name)
            if let existing = byParentAndName[key] {
                parent = existing
            } else {
                let folder = Folder(name: name, parent: parent)
                context.insert(folder)
                byParentAndName[key] = folder
                created += 1
                parent = folder
            }
        }
        return parent
    }

    private static func key(parent: Folder?, name: String) -> String {
        (parent?.uuid.uuidString ?? "") + "/" + SearchKey.fold(name)
    }
}
