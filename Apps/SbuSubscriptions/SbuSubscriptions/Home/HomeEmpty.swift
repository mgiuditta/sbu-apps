import SbuKit
import SwiftUI

/// The home before the first subscription: the title, then "0" waiting for something to count, on the paper's grid.
struct HomeEmpty: View {
    let today: Date
    let add: () -> Void

    var body: some View {
        // Scrollable, as the list under it: in a tab the audit read the fixed overlay's text as clipped.
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Abbonamenti", cartiglio: SpendingFigure.cartiglio(filterName: nil, today: today))
                SbuEmpty(sentence: "Aggiungi il tuo primo abbonamento: qui vedi quanto spendi.") {
                    SbuButton("Aggiungi", action: add)
                        .accessibilityIdentifier("addFirst")
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space6)
        }
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    HomeEmpty(today: .now) {}
        .environment(\.sbuAccent, .subscriptions)
}

#Preview("Dark") {
    HomeEmpty(today: .now) {}
        .environment(\.sbuAccent, .subscriptions)
        .preferredColorScheme(.dark)
}
