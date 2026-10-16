import SbuKit
import SwiftUI

/// A symbol, a title, a sentence and an optional action, centred on paper.
///
/// Laid out like `ContentUnavailableView`, but in a scroll view at least as tall as the screen:
/// centred at normal sizes, scrolling at the largest ones, where the system view clipped its text.
struct NoticeView<Actions: View>: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let systemImage: String
    /// A spinner instead of the symbol, while something is on its way.
    var isWaiting = false
    @ViewBuilder let actions: Actions

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    if isWaiting {
                        ProgressView()
                            .controlSize(.large)
                    } else {
                        Image(systemName: systemImage)
                            .font(SbuTheme.largeTitle)
                            .fontWeight(.medium)
                            .imageScale(.large)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .accessibilityHidden(true)
                    }

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
    NoticeView(title: "Ricerca in corso", message: "Tieni il dispositivo acceso e fuori dalla custodia: Sbu Find sente solo quello che trasmette.",systemImage: "magnifyingglass", isWaiting: true) {
        EmptyView()
    }
}

#Preview("Dark") {
    NoticeView(title: "Bluetooth spento", message: "Accendilo dal Centro di Controllo o in Impostazioni, poi torna qui.", systemImage: "antenna.radiowaves.left.and.right.slash") {
        SbuButton("Apri Impostazioni") {}
    }
    .preferredColorScheme(.dark)
}
