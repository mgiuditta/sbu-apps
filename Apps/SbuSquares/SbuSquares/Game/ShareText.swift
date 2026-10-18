import Foundation

/// The result to share, as plain text: score, lines, the board in ■ and □, and where to play.
nonisolated enum ShareText {
    static func make(for game: Game, locale: Locale = .current) -> String {
        let score = String(localized: "\(game.score) punti · \(game.lines) righe", locale: locale)
        let board = (0..<Board.size).map { row in
            String((0..<Board.size).map { game.board[Cell(row: row, column: $0)] ? "■" : "□" })
        }
        return (["Sbu Squares", score] + board + ["sbu.dev/games/squares"]).joined(separator: "\n")
    }
}
