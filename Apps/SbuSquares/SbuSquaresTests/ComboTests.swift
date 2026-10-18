import Testing
@testable import SbuSquares

struct ComboTests {
    @Test(arguments: [(0, 1, 0), (1, 1, 10), (2, 1, 20), (3, 1, 60), (4, 1, 120), (6, 1, 300), (1, 3, 30), (2, 2, 40), (1, 0, 10)])
    func linePointsGrowWithLinesAndCombo(lines: Int, combo: Int, points: Int) {
        #expect(Combo.linePoints(lines: lines, combo: combo) == points)
    }

    @Test func theStreakSurvivesTwoMissesAndEndsOnTheThird() {
        var combo = Combo()
        combo.record(lines: 1)
        combo.record(lines: 2)
        #expect(combo.count == 2)
        combo.record(lines: 0)
        combo.record(lines: 0)
        #expect(combo.count == 2)
        combo.record(lines: 1)
        #expect(combo.count == 3)
        for _ in 0..<3 { combo.record(lines: 0) }
        #expect(combo.count == 0)
    }
}
