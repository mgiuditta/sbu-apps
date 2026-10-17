import SbuKit
import SwiftUI

/// Nothing to list at all once the first seconds of the scan are over: the title, then the empty
/// state with Cerca di nuovo, on the grid paper.
struct NothingNearbyView: View {
    let cartiglio: String
    let searchAgain: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    SbuScreenTitle("Trova", cartiglio: cartiglio)

                    SbuEmpty(sentence: "Nessun dispositivo vicino. Tienilo acceso e fuori dalla custodia.") {
                        Button("Cerca di nuovo", action: searchAgain)
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.top, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                // The grid scrolls with the figure, so the figure stays on its line.
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview("Light") {
    NothingNearbyView(cartiglio: "Sbu · Trova · 0 dispositivi") {}
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NothingNearbyView(cartiglio: "Sbu · Trova · 0 dispositivi") {}
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
