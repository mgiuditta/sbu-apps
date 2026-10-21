import SbuKit
import SwiftUI

/// A tab with nothing to show yet: the screen title with its cartiglio, then the empty state on the grid paper.
struct TabScreen: View {
    let title: LocalizedStringKey
    let sentence: LocalizedStringKey

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    SbuScreenTitle(title, cartiglio: Cartiglio.today)
                    SbuEmpty(sentence: sentence) {
                        EmptyView()
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
    TabScreen(title: "Home", sentence: "Apri un social: qui conti i minuti di oggi.")
}

#Preview("Dark") {
    TabScreen(title: "Home", sentence: "Apri un social: qui conti i minuti di oggi.")
        .preferredColorScheme(.dark)
}
