import SbuKit
import SwiftUI

/// "Da ricomprare": the filled row marker and the word, in ink. The word says the state; the marker
/// only shows it at a glance.
struct LowStockBadge: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space2) {
            SbuRowMark(filled: true)
            Text("Da ricomprare")
                .font(SbuTheme.footnote)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.ink)
        }
    }
}

#Preview("Light") {
    LowStockBadge()
}

#Preview("Dark") {
    LowStockBadge()
        .preferredColorScheme(.dark)
}
