import Foundation
import Testing
@testable import SbuLevel

struct LevelModelTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "LevelModelTests-\(UUID().uuidString)"))
    }

    @Test func calibratingMakesTheCurrentPositionReadZero() {
        let model = LevelModel(defaults: defaults)
        model.update(with: Gravity(x: 0.05, y: -0.998, z: 0))
        #expect(model.reading.isLevel == false)

        model.calibrate()

        #expect(model.reading.isLevel)
        #expect(model.isCalibrated)
    }

    @Test func calibrationIsSavedOnTheDevice() {
        let first = LevelModel(defaults: defaults)
        first.update(with: Gravity(x: 0.05, y: -0.998, z: 0))
        first.calibrate()

        let second = LevelModel(defaults: defaults)

        #expect(second.calibration == first.calibration)
    }

    @Test func resetClearsTheCalibration() {
        let model = LevelModel(defaults: defaults)
        model.update(with: Gravity(x: 0.05, y: -0.998, z: 0))
        model.calibrate()

        model.resetCalibration()

        #expect(model.isCalibrated == false)
        #expect(LevelModel(defaults: defaults).isCalibrated == false)
    }

    @Test func calibratingWithoutASampleDoesNothing() {
        let model = LevelModel(defaults: defaults)

        model.calibrate()

        #expect(model.isCalibrated == false)
    }
}
