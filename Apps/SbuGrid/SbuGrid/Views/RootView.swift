import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell, with the gear drawn by the grid screen at the top left.
struct RootView: View {
    @State private var model: GridModel

    init(model: GridModel = .forLaunch()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        SbuAppShell("Sbu Grid", slug: "grid", accent: .grid, appIcon: Image(.appIconArtwork), settingsButtonPlacement: .content) {
            MainView(model: model)
        } settings: {
            HelpSection()
        }
    }
}

#Preview("Light") {
    RootView(model: .forLaunch(.demo))
}

#Preview("Dark") {
    RootView(model: .forLaunch(.demo))
        .preferredColorScheme(.dark)
}
