import SbuKit
import SwiftUI

/// A symbol, a title, a sentence and an optional action, centred on paper.
///
/// Laid out like `ContentUnavailableView`, but in a scroll view at least as tall as the screen:
/// centred at normal sizes, scrolling at the largest ones, where the system view clips its text.
struct NoticeView<Actions: View>: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let systemImage: String
    @ViewBuilder let actions: Actions

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    Image(systemName: systemImage)
                        .font(SbuTheme.largeTitle)
                        .fontWeight(.medium)
                        .imageScale(.large)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)

                    VStack(spacing: SbuTheme.space2) {
                        Text(title)
                            .font(SbuTheme.title2)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityAddTraits(.isHeader)

                        Text(message)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .multilineTextAlignment(.center)

                    actions
                        .padding(.top, SbuTheme.space2)
                }
                .padding(SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
        .background(SbuTheme.surface)
    }
}

#Preview("Light") {
    NoticeView(title: "Fotocamera non disponibile", message: "Per ricalcare serve la fotocamera posteriore. Puoi sempre copiare la foto cella per cella dallo schermo.", systemImage: "camera") {
        EmptyView()
    }
}

#Preview("Dark") {
    NoticeView(title: "Fotocamera non consentita", message: "Per ricalcare, consenti a Sbu Grid di usare la fotocamera in Impostazioni.", systemImage: "camera") {
        SbuButton("Apri Impostazioni") {}
    }
    .preferredColorScheme(.dark)
}
