import SbuKit
import SwiftUI

/// The first screen, before any photo: the title, the empty figure with what to do, and the
/// button to choose a photo, on the grid paper.
///
/// In a scroll view at least as tall as the screen, so the largest text sizes scroll instead of
/// clipping, and the grid scrolls with the figure.
struct EmptyPhotoView: View {
    let choosePhoto: () -> Void

    private var cartiglio: String {
        ["Sbu", String(localized: "Griglia"), String(localized: "Nessuna foto")].joined(separator: " · ")
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    SbuScreenTitle("Griglia", cartiglio: cartiglio)

                    SbuEmpty(sentence: "Scegli la foto da disegnare: Sbu Grid ci stende sopra una griglia, e tu la ricopi sul foglio una cella alla volta.") {
                        SbuButton("Scegli una foto", action: choosePhoto)
                    }

                    Text("Sbu Grid vede solo la foto che scegli, non la tua libreria.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.top, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        EmptyPhotoView(choosePhoto: {})
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        EmptyPhotoView(choosePhoto: {})
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
