import SbuKit
import SwiftUI

/// Where a chart goes while there is not enough data for it: what it needs, in words.
struct ChartPlaceholder: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    ChartPlaceholder(text: "Il grafico compare dal secondo voto.")
        .padding(SbuTheme.space4)
        .sbuPaper(grid: false)
}

#Preview("Dark") {
    ChartPlaceholder(text: "Il grafico compare dal secondo voto.")
        .padding(SbuTheme.space4)
        .sbuPaper(grid: false)
        .preferredColorScheme(.dark)
}
