import SbuKit
import SwiftUI

/// The game inside the standard Sbu shell.
struct RootView: View {
    @State private var store = GameStore()

    var body: some View {
        SbuAppShell("Sbu Sudoku", slug: "sudoku", accent: .sudoku, appIcon: Image(.appIconArtwork)) {
            MainView(store: store)
        } settings: {
            GameSettingsSection(store: store)
            RecordsSection(store: store)
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
