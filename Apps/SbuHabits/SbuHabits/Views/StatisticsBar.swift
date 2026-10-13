import SbuKit
import SwiftUI

/// The bar at the bottom of the Statistiche, as in Streaks: Condividi at the leading edge, the
/// pages in the middle, Chiudi at the trailing edge, both buttons in `ink` on raised paper.
struct StatisticsBar: View {
    let symbols: [String]
    let page: Int
    let turn: (Int) -> Void
    let close: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            // ponytail: Condividi keeps its place until "condividi le statistiche come immagine"
            // wires it; hidden, it is neither seen nor reached.
            Button("Condividi", systemImage: "square.and.arrow.up") {}
                .hidden()

            Spacer(minLength: 0)

            StatisticsPageIndicator(symbols: symbols, page: page, turn: turn)

            Spacer(minLength: 0)

            Button("Chiudi", systemImage: "xmark", action: close)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
    }
}

#Preview("Light") {
    StatisticsBar(symbols: ["drop", "book", "figure.walk"], page: 1, turn: { _ in }) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    StatisticsBar(symbols: ["drop", "book", "figure.walk"], page: 0, turn: { _ in }) {}
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
