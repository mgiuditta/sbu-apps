import SbuKit
import SwiftUI

/// Under the score, in `inkMuted`: the mistakes and the time, or why the last tap changed nothing.
struct StatusLine: View {
    let game: Game
    let preferences: Preferences
    let message: LocalizedStringResource?

    var body: some View {
        Group {
            if let message {
                Text(message)
            } else {
                Text(verbatim: parts.joined(separator: " · "))
            }
        }
        .font(SbuTheme.subheadline)
        .foregroundStyle(SbuTheme.inkMuted)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var parts: [String] {
        var parts: [String] = []
        if preferences.rules.checksMistakes {
            parts.append(game.hasMistakeLimit
                ? String(localized: "Errori \(game.mistakes) di \(Game.mistakeLimit)")
                : String(localized: "Errori \(game.mistakes)"))
        }
        if preferences.showsTimer {
            parts.append(Duration.seconds(Int(game.timePlayed)).formatted(.time(pattern: .minuteSecond)))
        }
        return parts
    }
}

#Preview("Light") {
    StatusLine(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), preferences: Preferences(), message: nil)
        .padding()
        .sbuPaper()
}

#Preview("Dark") {
    StatusLine(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), preferences: Preferences(), message: "Questa cifra è giusta.")
        .padding()
        .sbuPaper()
        .preferredColorScheme(.dark)
}
