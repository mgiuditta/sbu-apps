@testable import SbuSudoku

/// A known solution, and puzzles cut from it.
enum Fixtures {
    static let solution = """
    534678912\
    672195348\
    198342567\
    859761423\
    426853791\
    713924856\
    961537284\
    287419635\
    345286179
    """.map { Int(String($0))! }

    /// The solution with `empty` cells left for the player.
    static func puzzle(empty: Set<Int>) -> Puzzle {
        Puzzle(givens: solution.enumerated().map { empty.contains($0.offset) ? 0 : $0.element }, solution: solution)
    }

    /// The first row and the first column: a digit in the corner completes nothing.
    static let cross = Set(0..<9).union(stride(from: 0, to: 81, by: 9))

    /// A game on `difficulty` with `empty` cells, the first one selected.
    static func game(_ difficulty: Difficulty = .easy, empty: Set<Int> = cross, limit: Bool = true) -> Game {
        var game = Game(puzzle: puzzle(empty: empty), difficulty: difficulty, hasMistakeLimit: limit)
        game.selected = empty.min()
        return game
    }
}
