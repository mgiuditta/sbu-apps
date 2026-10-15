import SbuKit
import SwiftUI

/// An item in a list: first photo, name, where it is (in search) or its tags, "Da ricomprare" when low, how many.
struct ItemRow: View {
    let item: Item
    /// The folder path, shown in search results where the item could be anywhere.
    var path: String?

    var body: some View {
        let photo = item.sortedPhotos.first
        InventoryRowLayout(title: item.name, quantity: item.quantity) {
            RowTile(image: photo.flatMap { ThumbnailCache.image(for: $0.uuid, data: $0.thumbnail) }, systemImage: "shippingbox")
        } detail: {
            if let subtitle = path ?? (item.tags.isEmpty ? nil : item.tags.joined(separator: ", ")) {
                Text(subtitle)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            if item.isLow {
                LowStockBadge()
            }
        }
        .accessibilityIdentifier("item-\(item.name)")
    }
}

#Preview("Light") {
    List {
        ItemRow(item: Item(name: "Pile AA", quantity: 2), path: "Casa › Garage")
    }
}

#Preview("Dark") {
    List {
        ItemRow(item: Item(name: "Pile AA", quantity: 2))
    }
    .preferredColorScheme(.dark)
}
