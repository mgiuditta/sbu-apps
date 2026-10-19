import Foundation
import Testing
@testable import SbuSudoku

struct PuzzleTests {
    @Test(arguments: Difficulty.allCases)
    func aPuzzleHasOneSolutionAndTheDifficultysGivens(difficulty: Difficulty) {
        let puzzle = Puzzle(difficulty: difficulty, seed: 20_261_019)
        let givens = puzzle.givens.count { $0 != 0 }
        #expect(Solver.countSolutions(puzzle.givens) == 1)
        #expect(givens >= difficulty.givens.lowerBound)
        // Random removal rarely goes under 24 givens; Extreme may stop a little above its range.
        #expect(givens <= difficulty.givens.upperBound + (difficulty == .extreme ? 2 : 0))
        for (cell, value) in puzzle.givens.enumerated() where value != 0 {
            #expect(puzzle.solution[cell] == value)
        }
    }

    @Test func theSameSeedMakesTheSamePuzzle() {
        #expect(Puzzle(difficulty: .hard, seed: 42) == Puzzle(difficulty: .hard, seed: 42))
        #expect(Puzzle(difficulty: .hard, seed: 42) != Puzzle(difficulty: .hard, seed: 43))
    }

    @Test func aFilledGridIsValid() {
        var generator = SeededGenerator(seed: 7)
        let grid = Solver.filledGrid(using: &generator)
        for unit in Units.rows + Units.columns + Units.boxes {
            #expect(Set(unit.map { grid[$0] }) == Set(1...9))
        }
    }

    @Test func theSolverCountsUpToTheLimit() {
        #expect(Solver.countSolutions(Fixtures.solution) == 1)
        #expect(Solver.countSolutions(Array(repeating: 0, count: 81)) == 2)
        var broken = Fixtures.solution
        broken[1] = broken[0]
        #expect(Solver.countSolutions(broken) == 0)
    }

    @Test func theDailyPuzzleIsTheSameAllDayInUTC() {
        let morning = Date(timeIntervalSince1970: 1_792_368_000 + 60)
        let evening = Date(timeIntervalSince1970: 1_792_368_000 + 86_000)
        #expect(DailyPuzzle.day(of: morning) == DailyPuzzle.day(of: evening))
        #expect(DailyPuzzle.puzzle(for: DailyPuzzle.day(of: morning)) == DailyPuzzle.puzzle(for: DailyPuzzle.day(of: evening)))
    }
}
