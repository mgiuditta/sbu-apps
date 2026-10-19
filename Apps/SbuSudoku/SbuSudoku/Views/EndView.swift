import SbuKit
import SwiftUI

/// The end of a game, where the digits were: one sentence and what comes next. After the third
/// mistake, the second chance takes one mistake away; it is free and has no limit.
struct EndView<NewGame: View>: View {
    let game: Game
    let takeSecondChance: () -> Void
    @ViewBuilder let newGame: () -> NewGame

    private var sentence: Text {
        if game.failure == .mistakes {
            return Text("Hai fatto tre errori. Con la seconda possibilità ne togli uno e continui.")
        }
        let time = Duration.seconds(Int(game.timePlayed)).formatted(.time(pattern: .minuteSecond))
        return Text("Risolto in \(time).")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            sentence
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if game.failure != nil {
                Button("Seconda possibilità", action: takeSecondChance)
                    .buttonStyle(SbuButtonStyle(.primary))
            }
            newGame()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    EndView(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), takeSecondChance: {}) {
        Text("Nuova partita")
    }
    .padding()
    .sbuPaper()
}

#Preview("Dark") {
    EndView(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), takeSecondChance: {}) {
        Text("Nuova partita")
    }
    .padding()
    .sbuPaper()
    .preferredColorScheme(.dark)
}
