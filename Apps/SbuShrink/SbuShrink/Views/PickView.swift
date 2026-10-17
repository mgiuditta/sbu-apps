import SbuKit
import SwiftUI

/// The empty start: the title, the empty figure with what the app does, and where the videos
/// come from, on the grid paper. Photos opens the system picker, which asks for no permission.
///
/// In a scroll view at least as tall as the screen, so the largest text sizes scroll instead of
/// clipping, and the grid scrolls with the figure.
struct PickView: View {
    let pickPhotos: () -> Void
    let pickFiles: () -> Void

    /// The metadata line under the title: the app and today's date.
    private var cartiglio: String {
        String(localized: "Sbu · Riduci · \(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))")
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SbuTheme.space6) {
                    SbuScreenTitle("Riduci", cartiglio: cartiglio)

                    SbuEmpty(sentence: "Scegli uno o più video: diventano più leggeri e liberano spazio sull'iPhone.") {
                        VStack(spacing: SbuTheme.space3) {
                            SbuButton("Scegli da Foto", action: pickPhotos)
                            SbuButton("Importa da File", kind: .secondary, action: pickFiles)
                        }
                    }

                    Text("Tutto resta sul telefono.")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.top, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
                // Inside the scroll, so the grid and the figure's baseline move together.
                .sbuPaper(grid: true)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        PickView(pickPhotos: {}, pickFiles: {})
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        PickView(pickPhotos: {}, pickFiles: {})
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
