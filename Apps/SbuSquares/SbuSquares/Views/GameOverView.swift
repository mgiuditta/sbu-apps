import SbuKit
import SwiftUI

/// The end of a game, where the tray was: one sentence and the next game. While the second
/// chance is there, the sentence offers it and the game ends only when it is turned down.
struct GameOverView: View {
    let game: Game
    var canTakeBack = false
    var takeBack: () -> Void = {}
    var endGame: () -> Void = {}
    let playAgain: () -> Void

    private var sentence: LocalizedStringKey {
        if canTakeBack { return "Nessun pezzo entra più. Puoi rifare le ultime mosse, fino a tre, una volta a partita." }
        return game.beatsRecord ? "Nessun pezzo entra più, e hai battuto il record." : "Nessun pezzo entra più."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            Text(sentence)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if canTakeBack {
                Button("Rifai le ultime mosse", action: takeBack)
                    .buttonStyle(SbuButtonStyle(.primary))
                Button("Termina la partita", action: endGame)
                    .buttonStyle(SbuButtonStyle(.secondary))
            } else {
                Button("Gioca ancora", action: playAgain)
                    .buttonStyle(SbuButtonStyle(.primary))
            }
        }
    }
}

#Preview("Light") {
    GameOverView(game: Game(seed: 20_261_018, recordToBeat: 0), playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Second chance") {
    GameOverView(game: Game(seed: 1, recordToBeat: 0), canTakeBack: true, playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Dark") {
    GameOverView(game: Game(seed: 1, recordToBeat: 0), playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
