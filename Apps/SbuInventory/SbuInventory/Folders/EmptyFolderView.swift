import SbuKit
import SwiftUI

/// What an empty inventory or folder says: the figure 0 waiting and one sentence. The way to fill it,
/// `EmptyFolderActions`, follows on rows of its own.
///
/// It sits on a `List` row, so it holds its height with `SteadyFigure`.
struct EmptyFolderView: View {
    let isTop: Bool

    var body: some View {
        SteadyFigure { _ in
            SbuEmpty(sentence: isTop
                     ? "Aggiungi le cose che hai, con una foto, dove sono e quante."
                     : "Aggiungi qui gli oggetti o le cartelle che contiene.")
        }
    }
}

#Preview("Light") {
    EmptyFolderView(isTop: true)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
}

#Preview("Dark") {
    EmptyFolderView(isTop: false)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .preferredColorScheme(.dark)
}
