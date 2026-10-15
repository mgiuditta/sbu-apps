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

    // MARK: - Relative angle

    @Test(arguments: [(10.0, 25.0, 15.0), (25, 10, -15), (-5, 5, 10), (170, -170, 20)])
    func onAnEdgeTheFigureIsTheTurnSinceTheReference(from: Double, to: Double, expected: Double) {
        let readout = Readout(reading: edge(to), unit: .degrees, reference: edge(from))

        #expect(readout.isRelative)
        #expect(abs(readout.angle - expected) < 1e-9)
    }

    @Test func flatTheFigureIsTheChangeInTilt() {
        let reference = LevelReading(gravity: .lying(tiltedBy: 2), calibration: .none)
        let reading = LevelReading(gravity: .lying(tiltedBy: 5), calibration: .none)

        #expect(abs(Readout(reading: reading, unit: .degrees, reference: reference).angle - 3) < 1e-9)
    }

    @Test func backOnTheReferenceIsLevelEvenOnASideEdge() {
        // A side edge reads 90° when level; relative, the reference reads 0 and is the level.
        let readout = Readout(reading: edge(60), unit: .degrees, reference: edge(60))

        #expect(readout.angle == 0)
        #expect(readout.levelAngle == 0)
        #expect(readout.isLevel)
    }

    @Test(arguments: [
        (LevelReading(gravity: .standing(rotatedBy: 0), calibration: .none), LevelReading(gravity: .lying(tiltedBy: 3), calibration: .none)),
        (LevelReading(gravity: .standing(rotatedBy: 0), calibration: .none), LevelReading(gravity: .standing(rotatedBy: 90), calibration: .none)),
    ])
    func aReferenceFromAnotherModeOrEdgeDoesNotApply(reference: LevelReading, reading: LevelReading) {
        let readout = Readout(reading: reading, unit: .degrees, reference: reference)

        #expect(readout.isRelative == false)
        #expect(readout.angle == reading.angle)
    }

    @Test(arguments: [(AngleUnit.percent, -100.0), (.pitch, -12), (.ratio, -1), (.wholeDegrees, -45)])
    func relativeAnglesConvertWithTheirSign(unit: AngleUnit, expected: Double) {
        let readout = Readout(reading: edge(-15), unit: unit, reference: edge(30))

        #expect(unit.value(forDegrees: readout.angle) == expected)
    }

    @Test func aRelativeRatioAtZeroIsOffScaleButLevel() {
        let readout = Readout(reading: edge(12), unit: .ratio, reference: edge(12))

        #expect(AngleUnit.ratio.value(forDegrees: readout.angle) == nil)
        #expect(readout.isLevel)
    }
}
