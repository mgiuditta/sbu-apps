import SbuKit
import SwiftUI

/// "Da ricomprare": the word and its symbol in `warning`, never the color alone.
struct LowStockBadge: View {
    var body: some View {
        Label("Da ricomprare", systemImage: "cart")
            .font(SbuTheme.footnote)
            .fontWeight(.medium)
            .foregroundStyle(SbuTheme.warning)
            .labelStyle(.titleAndIcon)
    }
}

#Preview("Light") {
    LowStockBadge()
}

#Preview("Dark") {
    LowStockBadge()
        .preferredColorScheme(.dark)
}
