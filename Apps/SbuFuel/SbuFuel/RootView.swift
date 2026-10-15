import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Fuel", slug: "fuel", accent: SbuTheme.accentFuel, appIcon: Image(.appIconArtwork)) {
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
