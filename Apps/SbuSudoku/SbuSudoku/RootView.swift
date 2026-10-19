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
        #if DEBUG
        // UI tests and screenshots start inside a game: -newGame <difficulty>.
        .task {
            let arguments = ProcessInfo.processInfo.arguments
            if let index = arguments.firstIndex(of: "-newGame"), arguments.indices.contains(index + 1),
               let difficulty = Difficulty(rawValue: arguments[index + 1]), store.game == nil {
                await store.startGame(difficulty)
            }
        }
        #endif
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
