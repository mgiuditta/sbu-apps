import Testing
@testable import SbuLevel

struct ReadoutTests {
    private func edge(_ rotation: Double) -> LevelReading {
        LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none)
    }

    @Test(arguments: AngleUnit.allCases)
    func everyUnitIsLevelWhereTheDegreesAre(unit: AngleUnit) {
        for rotation in [0.0, 90, -90, 180] {
            #expect(Readout(reading: edge(rotation), unit: unit).isLevel)
        }
    }

    @Test func wholeDegreesAreLevelWhileTheFigureReadsZero() {
        #expect(Readout(reading: edge(0.4), unit: .wholeDegrees).isLevel)
        #expect(Readout(reading: edge(0.4), unit: .degrees).isLevel == false)
    }

    @Test func percentIsNotLevelWhenItsFigureIsNot() {
        // 0,04° reads 0,0° but 0,1 %: In bolla follows the figure shown.
        #expect(Readout(reading: edge(0.04), unit: .degrees).isLevel)
        #expect(Readout(reading: edge(0.04), unit: .percent).isLevel == false)
    }

    @Test func aSideEdgeNearlyLevelIsOffScaleOnlyAtLevel() {
        #expect(Readout(reading: edge(89.9), unit: .percent).isLevel == false)
        #expect(Readout(reading: edge(90), unit: .percent).isLevel)
    }
}
