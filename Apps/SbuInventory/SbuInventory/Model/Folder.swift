import Foundation
import SwiftData

/// A place or a container: Casa, Garage, Scatola 3. Folders nest to any depth.
///
/// Every property has a default and every relationship is optional, so the store can sync
/// through the user's iCloud (ADR-0008) without a migration.
@Model
final class Folder {
    /// Stable across launches, exports and devices.
    var uuid: UUID = UUID()
    var name: String = ""
    /// The folder it is in; `nil` at the top of the inventory.
    var parent: Folder?
    @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
    var children: [Folder]? = []
    @Relationship(deleteRule: .cascade, inverse: \Item.folder)
    var items: [Item]? = []
    /// The barcode or QR code already on the box, to open it by scanning.
    var code: String?
    var createdAt: Date = Date.now

    init(name: String, parent: Folder? = nil) {
        self.name = name
        self.parent = parent
    }
}
