import Testing
@testable import SbuSudoku

struct ScoringTests {
    let rules = Rules()

    @Test(arguments: [
        (Difficulty.easy, 50), (.medium, 150), (.hard, 210), (.expert, 230), (.evil, 250), (.extreme, 250),
    ])
    func aQuickCorrectCellScoresTheMostPoints(difficulty: Difficulty, points: Int) {
        var game = Fixtures.game(difficulty)
        game.enter(5, rules: rules)
        #expect(game.score == points)
    }

    @Test(arguments: [(0.0, 50), (4.9, 50), (5.0, 45), (12.0, 40), (44.9, 10), (45.0, 5), (600.0, 5)])
    func pointsFallATenthEveryFiveSeconds(seconds: Double, points: Int) {
        var game = Fixtures.game()
        game.addTime(seconds)
        game.enter(5, rules: rules)
        #expect(game.score == points)
    }

    @Test func everyFullGroupOfTheCellMultipliesByFive() {
        var game = Fixtures.game(empty: [0, 1])
        game.selected = 1
        game.enter(3, rules: rules)
        // Its column is full: × 5.
        #expect(game.score == 5 * 50)
        game.selected = 0
        game.addTime(12)
        game.enter(5, rules: rules)
        // Row, column and box are full, the column was full before too: × 15.
        #expect(game.score == 5 * 50 + 15 * 40)
    }

    @Test func aCellScoresOnce() {
        var game = Fixtures.game()
        game.enter(5, rules: rules)
        game.isNoting = false
        let rules = Rules(checksMistakes: false)
        game.enter(5, rules: rules) // clears
        game.enter(5, rules: rules)
        #expect(game.score == 50)
    }

    @Test func aWrongDigitScoresNothingAndCostsNothing() {
        var game = Fixtures.game()
        game.enter(5, rules: rules)
        game.selected = 1
        game.enter(1, rules: rules)
        #expect(game.score == 50)
    }

    @Test func aHintScoresTheMostPointsPlusTheMultipliedBase() {
        var game = Fixtures.game(empty: [0])
        game.addTime(12)
        game.hint(rules: rules)
        // Row, column and box: 50 + 15 × 40.
        #expect(game.score == 50 + 15 * 40)
    }

    @Test func aHintAloneScoresTheMostPoints() {
        var game = Fixtures.game(empty: [0, 1, 9])
        game.hint(rules: rules)
        #expect(game.score == 50)
    }

    @Test func undoKeepsThePoints() {
        var game = Fixtures.game(limit: false)
        game.enter(5, rules: Rules(checksMistakes: false))
        game.undo()
        #expect(game.score == 50)
    }
}
