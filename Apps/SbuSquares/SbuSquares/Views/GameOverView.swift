import SbuKit
import SwiftUI

/// The end of a game, where the tray was: one sentence and the next game.
struct GameOverView: View {
    let game: Game
    let playAgain: () -> Void

    private var sentence: LocalizedStringKey {
        game.beatsRecord ? "Nessun pezzo entra più, e hai battuto il record." : "Nessun pezzo entra più."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            Text(sentence)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Gioca ancora", action: playAgain)
                .buttonStyle(SbuButtonStyle(.primary))
        }
    }
}

#Preview("Light") {
    GameOverView(game: Game(seed: 20_261_018, recordToBeat: 0), playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Dark") {
    GameOverView(game: Game(seed: 1, recordToBeat: 0), playAgain: {})
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
