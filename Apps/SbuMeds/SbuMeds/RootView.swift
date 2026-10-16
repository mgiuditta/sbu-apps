import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Meds", slug: "meds", accent: SbuTheme.accentMeds, appIcon: Image(.appIconArtwork)) {
            MainView()
        } settings: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
