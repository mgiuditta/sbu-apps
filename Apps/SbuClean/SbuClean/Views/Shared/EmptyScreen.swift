import SbuKit
import SwiftUI

/// A whole screen with nothing in it yet: `SbuEmpty` on gridded paper, scrolling only when the
/// text is too large to fit.
struct EmptyScreen<Action: View>: View {
    let sentence: LocalizedStringKey
    @ViewBuilder let action: Action

    var body: some View {
        ScrollView {
            SbuEmpty(sentence: sentence) {
                action
            }
            .padding(SbuTheme.space4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sbuPaper(grid: true)
    }
}

extension EmptyScreen where Action == EmptyView {
    init(sentence: LocalizedStringKey) {
        self.init(sentence: sentence) { EmptyView() }
    }
}

#Preview("Light") {
    NavigationStack {
        EmptyScreen(sentence: "Non hai ancora album.")
    }
}

#Preview("Dark") {
    NavigationStack {
        EmptyScreen(sentence: "Nessun video nella libreria.")
    }
    .preferredColorScheme(.dark)
}
