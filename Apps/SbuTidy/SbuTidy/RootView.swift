import SbuKit
import SwiftData
import SwiftUI

/// The app inside the standard Sbu shell. "Now" moves on when the app comes back and at midnight.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var clock = Clock()

    var body: some View {
        SbuAppShell("Sbu Tidy", slug: "tidy", accent: SbuTheme.accentTidy, appIcon: Image(.appIconArtwork)) {
            TodayView()
        } settings: {
            EmptyView()
        }
        .environment(clock)
        .onChange(of: scenePhase, initial: true) {
            guard scenePhase == .active else { return }
            clock.refresh()
        }
        .task {
            await clock.runMidnights()
        }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(.preview)
}

#Preview("Dark") {
    RootView()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
