import SbuKit
import SwiftUI

/// The game inside the standard Sbu shell.
struct RootView: View {
    @State private var store = GameStore()

    var body: some View {
        SbuAppShell("Sbu Squares", slug: "squares", accent: .squares, appIcon: Image(.appIconArtwork)) {
            MainView(store: store)
        } settings: {
            RecordSection(store: store)
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
