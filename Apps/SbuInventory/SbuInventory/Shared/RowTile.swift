import SbuKit
import SwiftUI

/// The square at the start of a row: the item's first photo, or a symbol on sunken paper.
struct RowTile: View {
    let image: UIImage?
    let systemImage: String

    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 44

    var body: some View {
        ZStack {
            SbuTheme.surfaceSunken
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .frame(width: side, height: side)
        .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack {
        RowTile(image: nil, systemImage: "folder")
        RowTile(image: nil, systemImage: "shippingbox")
    }
    .padding(SbuTheme.space4)
}

#Preview("Dark") {
    HStack {
        RowTile(image: nil, systemImage: "folder")
        RowTile(image: nil, systemImage: "shippingbox")
    }
    .padding(SbuTheme.space4)
    .preferredColorScheme(.dark)
}
