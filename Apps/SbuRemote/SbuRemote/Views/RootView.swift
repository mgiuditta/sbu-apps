import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell; settings hold the saved TVs.
struct RootView: View {
    @State private var session: RemoteSession

    init(session: RemoteSession = RemoteSession(store: TVStore())) {
        _session = State(initialValue: session)
    }

    var body: some View {
        SbuAppShell("Sbu Remote", slug: "remote", accent: SbuTheme.accentRemote, appIcon: Image(.appIconArtwork)) {
            MainView(session: session)
        } settings: {
            SavedTVsSection(session: session)
        }
    }
}

#Preview("Light") {
    RootView(session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
}

#Preview("Dark") {
    RootView(session: RemoteSession(store: TVStore(defaults: UserDefaults(suiteName: "preview") ?? .standard)))
        .preferredColorScheme(.dark)
}
