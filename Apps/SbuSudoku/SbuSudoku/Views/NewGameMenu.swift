import SbuKit
import SwiftUI

/// The Sudoku of the day and the six difficulties, the proposed one first.
struct NewGameMenu<Label: View>: View {
    let proposed: Difficulty
    let hasPlayedDaily: Bool
    let start: (Difficulty) -> Void
    let startDaily: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Menu {
            Button(hasPlayedDaily ? "Del giorno: già giocato" : "Sudoku del giorno", systemImage: "calendar", action: startDaily)
                .disabled(hasPlayedDaily)
            Section("Ti propongo") {
                Button { start(proposed) } label: { Text(proposed.name) }
            }
            Section("Difficoltà") {
                ForEach(Difficulty.allCases) { difficulty in
                    Button { start(difficulty) } label: { Text(difficulty.name) }
                }
            }
        } label: {
            label()
        }
    }
}

#Preview("Light") {
    NewGameMenu(proposed: .hard, hasPlayedDaily: false, start: { _ in }, startDaily: {}) {
        Text("Nuova partita")
    }
}

#Preview("Dark") {
    NewGameMenu(proposed: .medium, hasPlayedDaily: true, start: { _ in }, startDaily: {}) {
        Text("Nuova partita")
    }
    .preferredColorScheme(.dark)
}
