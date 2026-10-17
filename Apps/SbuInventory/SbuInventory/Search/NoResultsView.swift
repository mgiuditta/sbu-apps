import SbuKit
import SwiftUI

/// A search that finds nothing: the figure 0 waiting and what to try, on paper.
struct NoResultsView: View {
    let search: String

    var body: some View {
        // No button: the search field is the way forward. SbuKit has no Text init without one.
        SbuEmpty(sentence: sentence) { EmptyView() }
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .sbuPaper(grid: true)
    }

    private var sentence: Text {
        if search.isEmpty {
            Text("Nessun risultato. Prova con un altro tag.")
        } else {
            Text("Nessun risultato per «\(search)». Prova con altre parole.")
        }
    }
}

#Preview("Light") {
    NoResultsView(search: "trapano")
}

#Preview("Dark") {
    NoResultsView(search: "")
        .preferredColorScheme(.dark)
}
