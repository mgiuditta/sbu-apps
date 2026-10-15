import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    var body: some View {
        SbuAppShell("Sbu Chats", slug: "chats", accent: SbuTheme.accentChats, appIcon: Image(.appIconArtwork)) {
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
