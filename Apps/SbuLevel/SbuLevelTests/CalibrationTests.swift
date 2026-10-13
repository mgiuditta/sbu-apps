import Foundation
import Testing
@testable import SbuLevel

struct CalibrationTests {
    /// A 2° slope and a sensor that reads 1° high, on one edge: the two readings straddle the slope.
    @Test(arguments: Edge.allCases)
    func twoStepsFindTheSensorErrorOnASlope(edge: Edge) throws {
        let slope = 2.0
        let error = 1.0
        let first = Gravity.standing(rotatedBy: edge.restingRotation + slope + error)
        let second = Gravity.standing(rotatedBy: edge.restingRotation - slope + error)

        let calibration = try #require(Calibration.none.calibrating(.edge(edge), first: first, second: second))

        #expect(abs(calibration.offset(for: edge) - error) < 1e-9)
        let reading = LevelReading(gravity: first, calibration: calibration)
        #expect(reading.edge == edge)
        #expect(abs(abs(reading.deviation) - slope) < 1e-9)
    }

    @Test func calibratingOneEdgeLeavesTheOthers() throws {
        var start = Calibration.none
        start.right = 0.5
        start.flatX = 0.01

        let calibration = try #require(start.calibrating(.edge(.bottom), first: .standing(rotatedBy: 3), second: .standing(rotatedBy: -1)))

        #expect(abs(calibration.bottom - 1) < 1e-9)
        #expect(calibration.right == 0.5)
        #expect(calibration.flatX == 0.01)
    }

    @Test func twoStepsOnASlopeLevelTheBubble() throws {
        // A 2° slope, tipped to the right, and a sensor that adds a constant error in x and y.
        let slope = sin(2 * Double.pi / 180)
        let errorX = 0.012
        let errorY = -0.008
        let first = Gravity(x: slope + errorX, y: errorY, z: -1)
        let second = Gravity(x: -slope + errorX, y: errorY, z: -1)

        let calibration = try #require(Calibration.none.calibrating(.flat, first: first, second: second))

        #expect(abs(calibration.flatX - errorX) < 1e-12)
        #expect(abs(calibration.flatY - errorY) < 1e-12)
        let reading = LevelReading(gravity: first, calibration: calibration)
        #expect(abs(reading.angle - 2) < 1e-6)
    }

    // MARK: - Plausibility

    /// More than 3° of sensor error, or a surface steeper than 10°, means the iPhone moved or was
    /// not turned in place: nothing is saved.
    @Test(arguments: [
        (2.9, 0.0, true), (-2.9, 0.0, true), (3.1, 0.0, false), (-3.1, 0.0, false),
        (0.0, 9.9, true), (0.0, 10.1, false), (1.0, 12.0, false),
    ])
    func anEdgeCalibrationOutsideTheLimitsIsRefused(error: Double, slope: Double, accepted: Bool) {
        for edge in Edge.allCases {
            let first = Gravity.standing(rotatedBy: edge.restingRotation + error + slope)
            let second = Gravity.standing(rotatedBy: edge.restingRotation + error - slope)

            let calibration = Calibration.none.calibrating(.edge(edge), first: first, second: second)

            #expect((calibration != nil) == accepted, "\(edge)")
        }
    }

    @Test(arguments: [
        (2.9, 0.0, true), (3.1, 0.0, false), (0.0, 9.9, true), (0.0, 10.1, false),
    ])
    func aFlatCalibrationOutsideTheLimitsIsRefused(errorDegrees: Double, slopeDegrees: Double, accepted: Bool) {
        let error = sin(errorDegrees * .pi / 180)
        let slope = sin(slopeDegrees * .pi / 180)
        // The error lies along y, the slope along x: both directions are checked.
        let first = Gravity(x: slope, y: error, z: -1)
        let second = Gravity(x: -slope, y: error, z: -1)

        let calibration = Calibration.none.calibrating(.flat, first: first, second: second)

        #expect((calibration != nil) == accepted)
    }

    // MARK: - Reset

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

    // MARK: - Saved data

    @Test func savedCalibrationRoundTrips() throws {
        var calibration = Calibration.none
        calibration.bottom = 0.3
        calibration.left = -0.7
        calibration.flatX = 0.01

        let data = try JSONEncoder().encode(calibration)

        #expect(try JSONDecoder().decode(Calibration.self, from: data) == calibration)
    }

    /// Exactly what the first build left on a real iPhone, which then read 9,2° flat on a table.
    @Test func theOneStepCalibrationOfTheFirstBuildIsDiscarded() throws {
        let data = Data(#"{"flatX":-0.14916,"edge":43.0747,"flatY":-0.07201}"#.utf8)

        let calibration = try JSONDecoder().decode(Calibration.self, from: data)

        #expect(calibration == .none)
        #expect(LevelReading(gravity: Gravity(x: 0, y: 0, z: -1), calibration: calibration).isLevel)
    }

    @Test(arguments: [
        #"{"bottom":0.5,"right":0,"top":0,"left":0,"flatX":0,"flatY":0}"#,
        #"{"version":1,"bottom":0.5,"flatX":0.01}"#,
        #"{"edge":0.2}"#,
    ])
    func dataWithoutTheCurrentVersionIsDiscarded(json: String) throws {
        #expect(try JSONDecoder().decode(Calibration.self, from: Data(json.utf8)) == .none)
    }

    @Test func implausibleSavedOffsetsAreIgnoredOneByOne() throws {
        // bottom and flat beyond 3°, right within.
        let json = #"{"version":2,"bottom":20,"right":-0.4,"top":0,"left":-3.5,"flatX":-0.14916,"flatY":-0.07201}"#

        let calibration = try JSONDecoder().decode(Calibration.self, from: Data(json.utf8))

        #expect(calibration.bottom == 0)
        #expect(calibration.right == -0.4)
        #expect(calibration.left == 0)
        #expect(calibration.flatX == 0)
        #expect(calibration.flatY == 0)
    }
}
