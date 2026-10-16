import SbuKit
import SwiftUI

/// The first screen, before any photo: what the app does, and the button to choose one.
///
/// Laid out like `ContentUnavailableView`, in a scroll view at least as tall as the screen, so
/// the largest text sizes scroll instead of clipping.
struct EmptyPhotoView: View {
    let choosePhoto: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    Image(systemName: "square.grid.3x3")
                        .font(SbuTheme.largeTitle)
                        .fontWeight(.medium)
                        .imageScale(.large)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)

                    VStack(spacing: SbuTheme.space2) {
                        Text("Nessuna foto")
                            .font(SbuTheme.title2)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityAddTraits(.isHeader)

                        Text("Scegli la foto da disegnare: Sbu Grid ci stende sopra una griglia, e tu la ricopi sul foglio una cella alla volta.")
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .multilineTextAlignment(.center)

                    SbuButton("Scegli una foto", action: choosePhoto)
                        .padding(.top, SbuTheme.space2)

                    Text("Sbu Grid vede solo la foto che scegli, non la tua libreria.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
        .background(SbuTheme.surface)
    }
}

#Preview("Light") {
    EmptyPhotoView(choosePhoto: {})
        .tint(SbuTheme.accentGrid)
}

#Preview("Dark") {
    EmptyPhotoView(choosePhoto: {})
        .tint(SbuTheme.accentGrid)
        .preferredColorScheme(.dark)
}
