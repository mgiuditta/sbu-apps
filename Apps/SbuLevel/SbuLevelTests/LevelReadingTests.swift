import Foundation
import Testing
@testable import SbuLevel

struct LevelReadingTests {
    /// Gravity for an iPhone tilted `degrees` away from lying flat, by lifting its top edge.
    private func pitched(by degrees: Double) -> Gravity {
        let radians = degrees * .pi / 180
        return Gravity(x: 0, y: -sin(radians), z: -cos(radians))
    }

    @Test(arguments: [
        (0.0, 0.0), (2.4, 2.4), (-7.5, 7.5), (30, 30), (44, 44), (46, 46), (60, 60), (-60, 60),
        (90, 90), (-90, 90), (120, 60), (150, 30), (180, 0), (-150, 30), (-120, 60),
    ])
    func edgeAngleIsTheDialReadingFrom0To90(rotation: Double, expected: Double) {
        let reading = LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none)

        #expect(reading.mode == .edge)
        #expect(abs(reading.angle - expected) < 1e-9)
    }

    @Test func aSixtyDegreeSlopeReadsSixtyNotThirty() {
        let reading = LevelReading(gravity: .standing(rotatedBy: 60), calibration: .none, previous: .init(gravity: .standing(rotatedBy: 0), calibration: .none))

        #expect(abs(reading.angle - 60) < 1e-9)
    }

    @Test(arguments: [
        (0.0, Edge.bottom, 0.0), (2, .bottom, 2), (-3, .bottom, -3),
        (90, .right, 0), (88, .right, -2), (-90, .left, 0), (-91, .left, -1),
        (180, .top, 0), (178, .top, -2), (-179, .top, 1),
    ])
    func eachEdgeIsRecognisedAndMeasuresItsOwnDeviation(rotation: Double, edge: Edge, deviation: Double) {
        let reading = LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none)

        #expect(reading.edge == edge)
        #expect(abs(reading.deviation - deviation) < 1e-9)
    }

    @Test(arguments: [0.0, 90, -90, 180])
    func everyEdgeLyingLevelIsInBolla(rotation: Double) {
        #expect(LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none).isLevel)
    }

    @Test(arguments: [
        (47.0, LevelMode?.some(.flat), LevelMode.flat),
        (47, .edge, .edge),
        (43, .edge, .edge),
        (43, .flat, .flat),
        (38, .edge, .flat),
        (52, .flat, .edge),
        (44, nil, .flat),
        (46, nil, .edge),
    ])
    func modeHoldsForFiveDegreesPastTheThreshold(tilt: Double, previous: LevelMode?, expected: LevelMode) {
        #expect(LevelReading.mode(for: pitched(by: tilt), previous: previous) == expected)
    }

    @Test func aReadingWobblingOnTheThresholdDoesNotFlicker() {
        var reading = LevelReading(gravity: pitched(by: 40), calibration: .none)
        var modes: Set<LevelMode> = []

        for tilt in [44.0, 46, 44, 47, 43, 46.5, 44.5] {
            reading = LevelReading(gravity: pitched(by: tilt), calibration: .none, previous: reading)
            modes.insert(reading.mode)
        }

        #expect(modes == [.flat])
    }

    @Test(arguments: [
        (48.0, Edge?.some(.bottom), Edge.bottom),
        (48, nil, .right),
        (52, .bottom, .right),
        (-48, .bottom, .bottom),
        (-52, .bottom, .left),
        (130, .right, .right),
        (141, .right, .top),
    ])
    func edgeHoldsForFiveDegreesPastTheDiagonal(rotation: Double, previous: Edge?, expected: Edge) {
        #expect(LevelReading.edge(for: rotation, previous: previous) == expected)
    }

    @Test(arguments: [0.0, 1.5, 5, 30])
    func flatAngleIsTiltFromHorizontal(tilt: Double) {
        let reading = LevelReading(gravity: .lying(tiltedBy: tilt), calibration: .none)

        #expect(reading.mode == .flat)
        #expect(reading.edge == nil)
        #expect(abs(reading.angle - tilt) < 1e-9)
    }

    @Test func bubbleFloatsToTheHighSideAndStopsAtTheEdge() {
        let slightly = LevelReading(gravity: .lying(tiltedBy: 5), calibration: .none)
        let steep = LevelReading(gravity: .lying(tiltedBy: 30), calibration: .none)

        // Right side lower: the bubble moves left.
        #expect(slightly.bubbleX < 0)
        #expect(slightly.bubbleX > -1)
        #expect(steep.bubbleX == -1)
        #expect(slightly.bubbleY == 0)
    }

    /// "In bolla" exactly when the figure shows the level angle, on every edge and flat.
    @Test(arguments: [
        (0.0, true), (0.04, true), (-0.04, true), (0.049, true), (0.051, false), (-0.06, false), (2.4, false),
        (90, true), (89.96, true), (90.04, true), (89.94, false), (-90.04, true), (-89.94, false),
        (180, true), (179.96, true), (-179.96, true), (179.94, false),
    ])
    func levelMeansTheFigureShowsTheLevelAngle(rotation: Double, isLevel: Bool) {
        let reading = LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none)

        #expect(reading.isLevel == isLevel)
    }

    @Test(arguments: [0.0, 0.04, 1.5, 3])
    func levelOnTheBubbleMeansTheFigureShowsZero(tilt: Double) {
        let reading = LevelReading(gravity: .lying(tiltedBy: tilt), calibration: .none)

        #expect(reading.isLevel == (tilt < 0.05))
    }

    /// Near zero on either side the figure reads "0,0", never "-0,0"; near 90 it reads "90,0".
    @Test(arguments: [
        (0.04, "it_IT", "0,0"), (-0.04, "it_IT", "0,0"), (-0.04, "en_US", "0.0"), (0.0, "it_IT", "0,0"),
        (-0.06, "it_IT", "0,1"), (89.96, "it_IT", "90,0"), (-89.96, "en_US", "90.0"), (180.04, "it_IT", "0,0"),
        (-179.96, "it_IT", "0,0"), (32.44, "it_IT", "32,4"), (32.46, "en_US", "32.5"),
    ])
    func theFigureNeverShowsMinusZero(rotation: Double, identifier: String, expected: String) {
        let reading = LevelReading(gravity: .standing(rotatedBy: rotation), calibration: .none)
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1)).locale(Locale(identifier: identifier))

        #expect(reading.displayedAngle.formatted(format) == expected)
    }

    /// A small tilt of the bubble near zero also reads "0,0".
    @Test func theBubbleNeverShowsMinusZero() {
        let reading = LevelReading(gravity: Gravity(x: -0.0005, y: 0.0003, z: -1), calibration: .none)
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1)).locale(Locale(identifier: "it_IT"))

        #expect(reading.displayedAngle.formatted(format) == "0,0")
        #expect(reading.isLevel)
    }

    /// The offset of each edge is subtracted: a sensor that reads `error` too far reads level once calibrated.
    @Test(arguments: Edge.allCases, [0.7, -0.7])
    func eachEdgeOffsetIsAppliedWithTheRightSign(edge: Edge, error: Double) {
        let calibration = Calibration.none.calibrating(
            .edge(edge),
            first: .standing(rotatedBy: edge.restingRotation + error),
            second: .standing(rotatedBy: edge.restingRotation + error)
        )

        let level = LevelReading(gravity: .standing(rotatedBy: edge.restingRotation + error), calibration: calibration)
        let tilted = LevelReading(gravity: .standing(rotatedBy: edge.restingRotation + error + 3), calibration: calibration)

        #expect(level.isLevel)
        #expect(abs(level.deviation) < 1e-9)
        #expect(abs(tilted.deviation - 3) < 1e-9)
        #expect(abs(abs(tilted.angle - level.angle) - 3) < 1e-9)
    }

    @Test func eachEdgeUsesItsOwnOffset() {
        var calibration = Calibration.none
        calibration.bottom = 1
        calibration.right = -2

        let bottom = LevelReading(gravity: .standing(rotatedBy: 1), calibration: calibration)
        let right = LevelReading(gravity: .standing(rotatedBy: 88), calibration: calibration)
        let top = LevelReading(gravity: .standing(rotatedBy: 179), calibration: calibration)

        #expect(abs(bottom.deviation) < 1e-9)
        #expect(abs(right.deviation) < 1e-9)
        #expect(abs(right.angle - 90) < 1e-9)
        #expect(abs(top.deviation + 1) < 1e-9)
    }

    @Test func calibrationTargetFollowsTheRestingSide() {
        #expect(LevelReading(gravity: .lying(tiltedBy: 2), calibration: .none).calibrationTarget == .flat)
        #expect(LevelReading(gravity: .standing(rotatedBy: -88), calibration: .none).calibrationTarget == .edge(.left))
    }

    @Test(arguments: [("it_IT", "2,4"), ("en_US", "2.4")])
    func angleIsFormattedWithOneDecimalForTheLocale(identifier: String, expected: String) {
        let reading = LevelReading(gravity: .standing(rotatedBy: -2.44), calibration: .none)
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1)).locale(Locale(identifier: identifier))

        #expect(reading.angle.formatted(format) == expected)
    }
}
