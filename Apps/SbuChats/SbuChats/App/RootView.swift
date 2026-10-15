import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let library: ChatLibrary

    var body: some View {
        SbuAppShell("Sbu Chats", slug: "chats", accent: SbuTheme.accentChats, appIcon: Image(.appIconArtwork)) {
            ChatsListView(library: library)
        } settings: {
            ChatsSettingsSection(knownOwners: library.knownOwners)
        }
    }
}

#Preview("Light") {
    RootView(library: .preview)
}

#Preview("Dark") {
    RootView(library: .preview)
        .preferredColorScheme(.dark)
}
