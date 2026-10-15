import SbuKit
import SwiftUI

/// A row of the inventory: tile, name, a line under it, the quantity on the right.
///
/// At the accessibility text sizes the tile goes and the quantity moves under the name, so the name
/// gets the whole width, as `SbuListRow` does.
struct InventoryRowLayout<Tile: View, Detail: View>: View {
    let title: String
    let quantity: Int
    @ViewBuilder let tile: Tile
    @ViewBuilder let detail: Detail

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var quantitySize = SbuTheme.statSmallSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(alignment: .center, spacing: SbuTheme.space3))
        layout {
            HStack(spacing: SbuTheme.space3) {
                if !dynamicTypeSize.isAccessibilitySize {
                    tile
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)
                    detail
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: SbuTheme.space2)
            }
            Text(quantity, format: .number)
                .font(SbuTheme.smallNumberFont(size: quantitySize))
                .foregroundStyle(SbuTheme.ink)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityValue(Text("Quantità \(quantity)"))
    }
}

#Preview("Light") {
    List {
        InventoryRowLayout(title: "Trapano", quantity: 2) {
            RowTile(image: nil, systemImage: "shippingbox")
        } detail: {
            Text(verbatim: "Casa › Garage")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }
}

#Preview("Dark") {
    List {
        InventoryRowLayout(title: "Trapano", quantity: 2) {
            RowTile(image: nil, systemImage: "shippingbox")
        } detail: {
            EmptyView()
        }
    }
    .preferredColorScheme(.dark)
}
