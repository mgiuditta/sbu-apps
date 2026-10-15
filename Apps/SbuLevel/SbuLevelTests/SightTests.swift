import AVFoundation
import Foundation
import Testing
@testable import SbuLevel

struct SightTests {
    /// Gravity for an iPhone held upright and tipped back by `degrees`, so the camera looks up.
    private func lookingUp(by degrees: Double) -> Gravity {
        let radians = degrees * .pi / 180
        return Gravity(x: 0, y: -cos(radians), z: sin(radians))
    }

    @Test(arguments: [0.0, 12, 45, -30, 89])
    func theFigureIsTheElevationOfTheLineOfSight(degrees: Double) {
        let reading = LevelReading.sight(gravity: lookingUp(by: degrees), calibration: .none)

        #expect(reading.mode == .sight)
        #expect(abs(reading.angle - degrees) < 1e-9)
    }

    @Test func lyingOnItsBackTheCameraLooksStraightDown() {
        #expect(abs(Gravity.lying(tiltedBy: 0).elevation + 90) < 1e-9)
    }

    @Test func theHorizonFollowsTheRoll() {
        let reading = LevelReading.sight(gravity: .standing(rotatedBy: 14), calibration: .none)

        #expect(abs(reading.rotation - 14) < 1e-9)
        #expect(abs(reading.angle) < 1e-9)
    }

    @Test func theFlatCalibrationCorrectsTheLineOfSight() {
        // A sensor that reads 1° of y tilt on a level surface reads the same 1° askew upright.
        let error = sin(Double.pi / 180)
        var calibration = Calibration.none
        calibration.flatY = error

        let reading = LevelReading.sight(gravity: Gravity(x: 0, y: -cos(.pi / 180), z: -error), calibration: calibration)

        #expect(abs(reading.angle) < 1e-9)
    }

    @Test func correctingByALevelSensorChangesNothing() {
        let gravity = Gravity(x: 0.2, y: -0.7, z: 0.1)

        #expect(gravity.correcting(level: Gravity(x: 0, y: 0, z: -1)) == gravity)
    }

    @Test func correctingTurnsTheLevelReadingStraightDown() {
        let level = Gravity(x: 0.03, y: -0.02, z: -(1 - 0.03 * 0.03 - 0.02 * 0.02).squareRoot())

        let corrected = level.correcting(level: level)

        #expect(abs(corrected.x) < 1e-9)
        #expect(abs(corrected.y) < 1e-9)
        #expect(abs(corrected.z + 1) < 1e-9)
    }

    @Test func relativeInSightIsTheChangeInElevation() {
        let reference = LevelReading.sight(gravity: lookingUp(by: 10), calibration: .none)
        let reading = LevelReading.sight(gravity: lookingUp(by: 25), calibration: .none)

        #expect(abs(Readout(reading: reading, unit: .degrees, reference: reference).angle - 15) < 1e-9)
    }

    @Test(arguments: [
        (AVAuthorizationStatus.authorized, true, CameraAccess.allowed),
        (.notDetermined, true, .notDetermined),
        (.denied, true, .denied),
        (.restricted, true, .denied),
        (.authorized, false, .unavailable),
        (.notDetermined, false, .unavailable),
    ])
    func cameraAccessFollowsTheAuthorization(status: AVAuthorizationStatus, hasCamera: Bool, expected: CameraAccess) {
        #expect(CameraAccess.from(status, hasCamera: hasCamera) == expected)
    }

    @Test(arguments: [(12.0, LevelStatus.aboveHorizon), (-3, .belowHorizon), (0.02, .onHorizon)])
    func theStatusSaysWhereTheLineOfSightPoints(degrees: Double, expected: LevelStatus) {
        let readout = Readout(reading: .sight(gravity: lookingUp(by: degrees), calibration: .none), unit: .degrees)

        #expect(LevelStatus(readout: readout, isLocked: false, camera: .allowed) == expected)
    }

    @Test(arguments: [(CameraAccess.unavailable, LevelStatus.cameraUnavailable), (.denied, .cameraDenied)])
    func withoutTheCameraTheStatusSaysWhy(access: CameraAccess, expected: LevelStatus) {
        let readout = Readout(reading: .sight(gravity: lookingUp(by: 5), calibration: .none), unit: .degrees)

        #expect(LevelStatus(readout: readout, isLocked: true, camera: access) == expected)
    }
}
