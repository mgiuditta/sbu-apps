import SbuKit
import SwiftUI

/// The empty start: what the app does in one line, and where the videos come from.
struct PickView: View {
    let pickPhotos: () -> Void
    let pickFiles: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    Image(systemName: "film.stack")
                        .font(SbuTheme.largeTitle)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)

                    Text("Comprimi i tuoi video")
                        .font(SbuTheme.title2)
                        .foregroundStyle(SbuTheme.ink)
                        .accessibilityAddTraits(.isHeader)

                    Text("Scegli uno o più video: diventano più leggeri e liberi spazio sull'iPhone. Tutto resta sul telefono.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.vertical, SbuTheme.space12)
                // Centred on the free space; it scrolls only when the text grows past it.
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: SbuTheme.space3) {
                SbuButton("Scegli da Foto", action: pickPhotos)
                SbuButton("Importa da File", kind: .secondary, action: pickFiles)
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space3)
            .background(SbuTheme.surface)
        }
    }
}

#Preview("Light") {
    PickView(pickPhotos: {}, pickFiles: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
}

#Preview("Dark") {
    PickView(pickPhotos: {}, pickFiles: {})
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentShrink)
        .preferredColorScheme(.dark)
}
