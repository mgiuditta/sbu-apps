import SbuKit
import SwiftUI

/// Undo, erase, notes and hint.
struct ActionBar: View {
    let game: Game
    let undo: () -> Void
    let erase: () -> Void
    let toggleNoting: () -> Void
    let hint: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            ActionButton(title: "Annulla", systemImage: "arrow.uturn.backward", action: undo)
                .disabled(!game.canUndo)
            ActionButton(title: "Cancella", systemImage: "eraser", action: erase)
            ActionButton(title: "Note", systemImage: "pencil", isOn: game.isNoting, action: toggleNoting)
                .accessibilityValue(game.isNoting ? Text("Attive") : Text("Spente"))
            ActionButton(title: "Suggerimento", systemImage: "lightbulb", action: hint)
        }
    }
}

#Preview("Light") {
    ActionBar(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), undo: {}, erase: {}, toggleNoting: {}, hint: {})
        .padding()
        .sbuPaper()
}

#Preview("Dark") {
    ActionBar(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), undo: {}, erase: {}, toggleNoting: {}, hint: {})
        .padding()
        .sbuPaper()
        .preferredColorScheme(.dark)
}
