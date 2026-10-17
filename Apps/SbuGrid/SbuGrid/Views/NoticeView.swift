import SbuKit
import SwiftUI

/// Why tracing cannot start yet: a title, then `SbuEmpty` with the sentence and an optional
/// action, on the grid paper.
///
/// In a scroll view at least as tall as the screen, so the largest text sizes scroll instead of
/// clipping.
struct NoticeView<Actions: View>: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    @ViewBuilder let actions: Actions

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    Text(title)
                        .font(SbuTheme.title2)
                        .foregroundStyle(SbuTheme.ink)
                        .accessibilityAddTraits(.isHeader)

                    SbuEmpty(sentence: Text(message)) {
                        actions
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.top, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NoticeView(title: "Fotocamera non disponibile", message: "Per ricalcare serve la fotocamera posteriore. Puoi sempre copiare la foto cella per cella dallo schermo.") {
        EmptyView()
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NoticeView(title: "Fotocamera non consentita", message: "Per ricalcare, consenti a Sbu Grid di usare la fotocamera in Impostazioni.") {
        SbuButton("Apri Impostazioni") {}
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
