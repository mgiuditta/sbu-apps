import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Inventory", slug: "inventory", accent: SbuTheme.accentInventory, appIcon: Image(.appIconArtwork)) {
            Color.clear
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
