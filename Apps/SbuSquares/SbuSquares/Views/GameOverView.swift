import SbuKit
import SwiftUI

/// The end of a game, where the tray was: one sentence, the result to share, the next game.
struct GameOverView: View {
    let game: Game
    let shareText: String
    let playAgain: () -> Void

    private var sentence: LocalizedStringKey {
        switch (game.mode, game.beatsRecord) {
        case (.daily, true): "Partita del giorno finita, con il record. Domani ne hai un'altra, uguale per tutti."
        case (.daily, false): "Partita del giorno finita. Domani ne hai un'altra, uguale per tutti."
        case (.free, true): "Nessun pezzo entra più, e hai battuto il record."
        case (.free, false): "Nessun pezzo entra più."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            Text(sentence)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: SbuTheme.space2) {
                ShareLink(item: shareText) {
                    Text("Condividi")
                }
                .buttonStyle(SbuButtonStyle(.primary))
                Button(game.mode == .daily ? "Gioca libera" : "Gioca ancora", action: playAgain)
                    .buttonStyle(SbuButtonStyle(.secondary))
            }
        }
    }
}

#Preview("Light") {
    GameOverView(game: Game(mode: .daily, seed: 20_261_018, recordToBeat: 0), shareText: "Sbu Squares", playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Dark") {
    GameOverView(game: Game(mode: .free, seed: 1, recordToBeat: 0), shareText: "Sbu Squares", playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
