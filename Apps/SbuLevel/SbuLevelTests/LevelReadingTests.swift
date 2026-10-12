import Foundation
import Testing
@testable import SbuLevel

struct LevelReadingTests {
    /// Gravity for an iPhone standing on an edge, rotated by `degrees` in the screen plane.
    private func standing(rotatedBy degrees: Double) -> Gravity {
        let radians = degrees * .pi / 180
        return Gravity(x: sin(radians), y: -cos(radians), z: 0)
    }

    /// Gravity for an iPhone lying on its back, tilted by `degrees` around its long axis.
    private func lying(tiltedBy degrees: Double) -> Gravity {
        let radians = degrees * .pi / 180
        return Gravity(x: sin(radians), y: 0, z: -cos(radians))
    }

    @Test(arguments: [
        (0.0, 0.0), (2.4, 2.4), (-7.5, -7.5), (30, 30), (90, 0), (-90, 0), (95, 5), (180, 0), (44, 44), (46, -44),
    ])
    func edgeAngleIsDeviationFromNearestRightAngle(rotation: Double, expected: Double) {
        let reading = LevelReading(gravity: standing(rotatedBy: rotation), calibration: .none)

        #expect(reading.mode == .edge)
        #expect(abs(reading.angle - expected) < 1e-9)
    }

    @Test(arguments: [0.0, 1.5, 5, 30])
    func flatAngleIsTiltFromHorizontal(tilt: Double) {
        let reading = LevelReading(gravity: lying(tiltedBy: tilt), calibration: .none)

        #expect(reading.mode == .flat)
        #expect(abs(reading.angle - tilt) < 1e-9)
    }

    @Test func bubbleFloatsToTheHighSideAndStopsAtTheEdge() {
        let slightly = LevelReading(gravity: lying(tiltedBy: 5), calibration: .none)
        let steep = LevelReading(gravity: lying(tiltedBy: 30), calibration: .none)

        // Right side lower: the bubble moves left.
        #expect(slightly.bubbleX < 0)
        #expect(slightly.bubbleX > -1)
        #expect(steep.bubbleX == -1)
        #expect(slightly.bubbleY == 0)
    }

    @Test(arguments: [(0.0, true), (0.04, true), (0.05, false), (-0.04, true), (2.4, false)])
    func levelMeansTheAngleRoundsToZero(angle: Double, isLevel: Bool) {
        #expect(LevelReading(mode: .edge, angle: angle, bubbleX: 0, bubbleY: 0).isLevel == isLevel)
    }

    @Test func calibrationZeroesTheCurrentModeOnly() {
        let calibration = Calibration.none.levelling(standing(rotatedBy: 2)).levelling(lying(tiltedBy: 3))

        let edge = LevelReading(gravity: standing(rotatedBy: 2), calibration: calibration)
        let flat = LevelReading(gravity: lying(tiltedBy: 3), calibration: calibration)
        let tiltedFurther = LevelReading(gravity: standing(rotatedBy: 12), calibration: calibration)

        #expect(abs(edge.angle) < 1e-9)
        #expect(abs(flat.angle) < 1e-9)
        #expect(abs(tiltedFurther.angle - 10) < 1e-9)
    }

    @Test(arguments: [("it_IT", "2,4"), ("en_US", "2.4")])
    func angleIsFormattedWithOneDecimalForTheLocale(identifier: String, expected: String) {
        let reading = LevelReading(gravity: standing(rotatedBy: -2.44), calibration: .none)
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1)).locale(Locale(identifier: identifier))

        #expect(reading.magnitude.formatted(format) == expected)
    }
}
