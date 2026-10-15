import Foundation
import SwiftData

/// One photo of an item: the image at most 2048 px, already upright, and a small thumbnail for lists.
@Model
final class ItemPhoto {
    /// Names the photo in an export and in the thumbnail cache.
    var uuid: UUID = UUID()
    @Attribute(.externalStorage) var data: Data?
    var thumbnail: Data?
    /// Position among the item's photos; the first is the one in lists.
    var order: Int = 0
    var item: Item?

    init(data: Data, thumbnail: Data, order: Int) {
        self.data = data
        self.thumbnail = thumbnail
        self.order = order
    }
}
