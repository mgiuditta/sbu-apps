import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Duo", slug: "duo", accent: SbuTheme.accentDuo, appIcon: Image(.appIconArtwork)) {
            GiftsView()
        } settings: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(.duoPreview)
}

#Preview("Dark") {
    RootView()
        .modelContainer(.duoPreview)
        .preferredColorScheme(.dark)
}
