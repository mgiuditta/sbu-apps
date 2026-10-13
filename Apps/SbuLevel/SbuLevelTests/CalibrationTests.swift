import Foundation
import Testing
@testable import SbuLevel

struct CalibrationTests {
    /// A 2° slope and a sensor that reads 1° high, on one edge: the two readings straddle the slope.
    @Test(arguments: Edge.allCases)
    func twoStepsFindTheSensorErrorOnASlope(edge: Edge) {
        let slope = 2.0
        let error = 1.0
        let first = Gravity.standing(rotatedBy: edge.restingRotation + slope + error)
        let second = Gravity.standing(rotatedBy: edge.restingRotation - slope + error)

        let calibration = Calibration.none.calibrating(.edge(edge), first: first, second: second)

        #expect(abs(calibration.offset(for: edge) - error) < 1e-9)
        let reading = LevelReading(gravity: first, calibration: calibration)
        #expect(reading.edge == edge)
        #expect(abs(abs(reading.deviation) - slope) < 1e-9)
    }

    @Test func calibratingOneEdgeLeavesTheOthers() {
        var start = Calibration.none
        start.right = 0.5
        start.flatX = 0.01

        let calibration = start.calibrating(.edge(.bottom), first: .standing(rotatedBy: 3), second: .standing(rotatedBy: -1))

        #expect(abs(calibration.bottom - 1) < 1e-9)
        #expect(calibration.right == 0.5)
        #expect(calibration.flatX == 0.01)
    }

    @Test func twoStepsOnASlopeLevelTheBubble() {
        // A 2° slope, tipped to the right, and a sensor that adds a constant error in x and y.
        let slope = sin(2 * Double.pi / 180)
        let errorX = 0.012
        let errorY = -0.008
        let first = Gravity(x: slope + errorX, y: errorY, z: -1)
        let second = Gravity(x: -slope + errorX, y: errorY, z: -1)

        let calibration = Calibration.none.calibrating(.flat, first: first, second: second)

        #expect(abs(calibration.flatX - errorX) < 1e-12)
        #expect(abs(calibration.flatY - errorY) < 1e-12)
        let reading = LevelReading(gravity: first, calibration: calibration)
        #expect(abs(reading.angle - 2) < 1e-6)
    }

    @Test func resettingOneSideKeepsTheOthers() {
        var calibration = Calibration.none
        calibration.left = 1
        calibration.top = -1
        calibration.flatY = 0.02

        let reset = calibration.resetting(.edge(.left))

        #expect(reset.isCalibrated(.edge(.left)) == false)
        #expect(reset.calibratedTargets == [.flat, .edge(.top)])
        #expect(reset.resetting(.flat).resetting(.edge(.top)) == .none)
    }

    @Test func savedCalibrationRoundTrips() throws {
        var calibration = Calibration.none
        calibration.bottom = 0.3
        calibration.left = -0.7
        calibration.flatX = 0.01

        let data = try JSONEncoder().encode(calibration)

        #expect(try JSONDecoder().decode(Calibration.self, from: data) == calibration)
    }

    /// The first builds saved one offset for every edge: it keeps working until the user calibrates again.
    @Test func aOneStepCalibrationFromBeforeAppliesToEveryEdge() throws {
        let data = Data(#"{"edge":1.5,"flatX":0.01,"flatY":-0.02}"#.utf8)

        let calibration = try JSONDecoder().decode(Calibration.self, from: data)

        #expect(Edge.allCases.allSatisfy { calibration.offset(for: $0) == 1.5 })
        #expect(calibration.flatX == 0.01)
        #expect(calibration.flatY == -0.02)
        // It reads exactly as before: 1,5° of rotation was the old level on any edge.
        #expect(LevelReading(gravity: .standing(rotatedBy: 91.5), calibration: calibration).isLevel)
    }
}
