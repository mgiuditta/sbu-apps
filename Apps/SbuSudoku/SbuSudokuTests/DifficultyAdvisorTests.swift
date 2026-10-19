import Foundation
import Testing
@testable import SbuSudoku

struct DifficultyAdvisorTests {
    let now = Date(timeIntervalSince1970: 1_792_400_000)

    func wins(_ counts: [Difficulty: Int], daysAgo: Double = 1) -> [Win] {
        counts.flatMap { difficulty, count in
            Array(repeating: Win(date: now.addingTimeInterval(-daysAgo * 86_400), difficulty: difficulty), count: count)
        }
    }

    @Test func fewerThanThreeRecentWinsMeanHard() {
        #expect(DifficultyAdvisor.level(wins: wins([.easy: 2]), now: now) == .hard)
        #expect(DifficultyAdvisor.level(wins: wins([.easy: 5], daysAgo: 8), now: now) == .hard)
    }

    @Test func theMostWonDifficultyIsTheLevel() {
        #expect(DifficultyAdvisor.level(wins: wins([.easy: 5, .expert: 3]), now: now) == .easy)
    }

    @Test func theHardestWonCountsWhenWonAlmostAsOften() {
        #expect(DifficultyAdvisor.level(wins: wins([.easy: 5, .expert: 4]), now: now) == .expert)
    }

    @Test(arguments: [(0.0, Difficulty.medium), (0.09, .medium), (0.1, .hard), (0.79, .hard), (0.8, .expert), (0.99, .expert)])
    func theProposalIsDrawnAroundTheLevel(draw: Double, expected: Difficulty) {
        #expect(DifficultyAdvisor.proposal(wins: [], now: now, draw: draw) == expected)
    }
}
