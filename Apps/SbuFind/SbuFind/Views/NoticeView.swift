import SbuKit
import SwiftUI

/// Why nothing can be heard: a title, then `SbuEmpty` with the sentence and an optional action, on
/// the grid paper.
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

                    // SbuEmpty takes a key: the localized sentence is its own key, and shows as is.
                    SbuEmpty(sentence: LocalizedStringKey(String(localized: message))) {
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
    NoticeView(title: "Bluetooth non consentito", message: "Per sentire i dispositivi vicini, consenti il Bluetooth a Sbu Find in Impostazioni. Quello che sente resta sull'iPhone.") {
        EmptyView()
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NoticeView(title: "Bluetooth spento", message: "Accendilo dal Centro di Controllo o in Impostazioni, poi torna qui.") {
        Button("Apri Impostazioni") {}
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
