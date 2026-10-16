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
            .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    List {
        ChartPlaceholder(text: "Il grafico compare dal secondo voto.")
    }
}

#Preview("Dark") {
    List {
        ChartPlaceholder(text: "Il grafico compare dal secondo voto.")
    }
    .preferredColorScheme(.dark)
}
