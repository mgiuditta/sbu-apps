import Testing
@testable import SbuSudoku

struct GameTests {
    let rules = Rules()

    @Test func aDigitThatDiffersFromTheSolutionIsAMistake() {
        var game = Fixtures.game()
        game.enter(1, rules: rules)
        #expect(game.state(of: 0, rules: rules) == .error)
        #expect(game.mistakes == 1)
    }

    @Test func theSameWrongDigitAgainCountsAgain() {
        var game = Fixtures.game()
        game.enter(1, rules: rules)
        game.enter(1, rules: rules) // same digit: clears
        game.enter(1, rules: rules)
        #expect(game.mistakes == 2)
    }

    @Test func uncheckedMistakesAreNeitherShownNorCounted() {
        var game = Fixtures.game()
        let unchecked = Rules(checksMistakes: false)
        game.enter(1, rules: unchecked)
        #expect(game.state(of: 0, rules: unchecked) == .ok)
        #expect(game.mistakes == 0)
    }

    @Test func theThirdMistakeEndsTheGame() {
        var game = Fixtures.game()
        for digit in [1, 2, 3] {
            game.enter(digit, rules: rules)
        }
        #expect(game.failure == .mistakes)
        #expect(game.isOver)
    }

    @Test func withoutTheLimitMistakesNeverEndTheGame() {
        var game = Fixtures.game(limit: false)
        for digit in [1, 2, 3, 4] {
            game.enter(digit, rules: rules)
        }
        #expect(game.mistakes == 4)
        #expect(game.failure == nil)
    }

    @Test func theSecondChanceTakesOneMistakeAway() {
        var game = Fixtures.game()
        for digit in [1, 2, 3] {
            game.enter(digit, rules: rules)
        }
        game.takeSecondChance()
        #expect(game.mistakes == 2)
        #expect(!game.isOver)
        game.enter(4, rules: rules)
        #expect(game.failure == .mistakes)
    }

    @Test func tappingTheSameDigitClearsTheCell() {
        var game = Fixtures.game()
        game.enter(1, rules: rules)
        #expect(game.enter(1, rules: rules) == .erased)
        #expect(game.value(at: 0) == 0)
    }

    @Test func aCorrectCellCannotBeChangedWhileMistakesAreChecked() {
        var game = Fixtures.game()
        game.enter(5, rules: rules)
        #expect(game.enter(1, rules: rules) == .alreadyCorrect)
        #expect(game.erase(rules: rules) == .alreadyCorrect)
        #expect(game.value(at: 0) == 5)
    }

    @Test func givenCellsCannotChange() {
        var game = Fixtures.game()
        game.selected = 10
        #expect(game.enter(1, rules: rules) == .given)
    }

    @Test func aNoteClearsTheDigitAndADigitClearsTheNotes() {
        var game = Fixtures.game()
        game.enter(1, rules: rules)
        game.isNoting = true
        game.enter(2, rules: rules)
        #expect(game.value(at: 0) == 0)
        #expect(game.notes(at: 0) == 1 << 2)
        game.isNoting = false
        game.enter(3, rules: rules)
        #expect(game.notes(at: 0) == 0)
    }

    @Test func aDigitLeavesTheNotesOfItsRowColumnAndBox() {
        var game = Fixtures.game(empty: [0, 1, 27, 80])
        game.isNoting = true
        for cell in [1, 27, 80] {
            game.selected = cell
            game.enter(5, rules: rules)
        }
        game.isNoting = false
        game.selected = 0
        game.enter(5, rules: rules)
        #expect(game.notes(at: 1) == 0)
        #expect(game.notes(at: 27) == 0)
        #expect(game.notes(at: 80) == 1 << 5)
    }

    @Test func undoRestoresTheCellButNotTheMistakes() {
        var game = Fixtures.game()
        game.enter(1, rules: rules)
        game.undo()
        #expect(game.value(at: 0) == 0)
        #expect(game.mistakes == 1)
    }

    @Test func undoKeepsTwentyFiveSteps() {
        var game = Fixtures.game(limit: false)
        game.isNoting = true
        for _ in 0..<30 {
            game.enter(1, rules: rules)
        }
        #expect(game.history.count == Game.historyLimit)
    }

    @Test func undoLeavesACellPlacedByAHint() {
        var game = Fixtures.game()
        game.isNoting = true
        game.enter(2, rules: rules)
        game.isNoting = false
        game.hint(rules: rules)
        game.undo()
        #expect(game.value(at: 0) == 5)
        #expect(!game.isMutable(0))
    }

    @Test func aHintRevealsTheSelectedCellAndLocksIt() {
        var game = Fixtures.game()
        game.selected = 4
        #expect(game.hint(rules: rules) == .placed)
        #expect(game.value(at: 4) == 7)
        #expect(game.state(of: 4, rules: rules) == .constant)
        #expect(game.hint(rules: rules) == .given)
    }

    @Test func remainingCountsWrongDigitsToo() {
        var game = Fixtures.game()
        #expect(game.remaining(5) == 1)
        game.selected = 2
        game.enter(5, rules: rules)
        #expect(game.remaining(5) == 0)
    }

    @Test func fillingTheSolutionSolvesTheGame() {
        var game = Fixtures.game(empty: Set(0..<9))
        for cell in 0..<9 {
            game.selected = cell
            game.enter(Fixtures.solution[cell], rules: rules)
        }
        #expect(game.isSolved)
        #expect(game.enter(1, rules: rules) == .ignored)
    }

    @Test func uncheckedWrongDigitsLeaveTheGridFilledButNotSolved() {
        var game = Fixtures.game(empty: [0, 1])
        let unchecked = Rules(checksMistakes: false)
        game.enter(3, rules: unchecked)
        game.selected = 1
        game.enter(5, rules: unchecked)
        #expect(game.isFilledWrong)
    }
}
