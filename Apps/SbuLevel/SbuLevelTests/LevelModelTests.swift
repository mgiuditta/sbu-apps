import Foundation
import Testing
@testable import SbuLevel

struct LevelModelTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "LevelModelTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> LevelModel {
        LevelModel(defaults: defaults, source: FixedGravitySource(gravity: .standing(rotatedBy: 0)))
    }

    /// Runs one two-step calibration: `first` and then `second`, each held steady for a second.
    private func calibrate(_ model: LevelModel, first: Gravity, second: Gravity) {
        model.startCalibration()
        model.captureCalibrationStep()
        for _ in 0..<StableSampler.sampleCount { model.update(with: first) }
        model.captureCalibrationStep()
        for _ in 0..<StableSampler.sampleCount { model.update(with: second) }
    }

    @Test func lockFreezesTheShownReading() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 12))

        model.toggleLock()
        model.update(with: .standing(rotatedBy: 40))

        #expect(model.isLocked)
        #expect(abs(model.reading.angle - 12) < 1e-9)
        #expect(abs(model.liveReading.angle - 40) < 1e-9)
    }

    @Test func unlockingFollowsTheSensorAgain() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 12))
        model.toggleLock()
        model.update(with: .standing(rotatedBy: 40))

        model.toggleLock()

        #expect(model.isLocked == false)
        #expect(abs(model.reading.angle - 40) < 1e-9)
    }

    @Test func aLockedReadingDoesNotTurnLevel() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 5))
        model.toggleLock()

        model.update(with: .standing(rotatedBy: 0))

        #expect(model.reading.isLevel == false)
    }

    @Test func twoStepCalibrationIsSavedForThatSide() {
        let model = makeModel()

        calibrate(model, first: .standing(rotatedBy: 3), second: .standing(rotatedBy: -1))

        #expect(model.calibrationSession?.step == .done)
        #expect(abs(model.calibration.bottom - 1) < 1e-9)
        #expect(model.calibration.calibratedTargets == [.edge(.bottom)])
        #expect(LevelModel(defaults: defaults).calibration == model.calibration)
    }

    @Test func calibrationAppliesToTheLiveReadingAtOnce() {
        let model = makeModel()

        calibrate(model, first: .standing(rotatedBy: 1), second: .standing(rotatedBy: 1))

        #expect(model.reading.isLevel)
    }

    @Test func endingTheCalibrationClosesTheSession() {
        let model = makeModel()
        model.startCalibration()

        model.endCalibration()

        #expect(model.calibrationSession == nil)
        #expect(model.isCalibrated == false)
    }

    @Test func resettingOneSideKeepsTheOthers() {
        let model = makeModel()
        calibrate(model, first: .standing(rotatedBy: 1), second: .standing(rotatedBy: 1))
        calibrate(model, first: .standing(rotatedBy: 91), second: .standing(rotatedBy: 91))

        model.resetCalibration(.edge(.bottom))

        #expect(model.calibration.calibratedTargets == [.edge(.right)])
        #expect(LevelModel(defaults: defaults).calibration.calibratedTargets == [.edge(.right)])
    }

    @Test func resettingEverythingClearsTheCalibration() {
        let model = makeModel()
        calibrate(model, first: .standing(rotatedBy: 1), second: .standing(rotatedBy: 1))

        model.resetCalibration()

        #expect(model.isCalibrated == false)
        #expect(LevelModel(defaults: defaults).isCalibrated == false)
    }

    @Test func screenStaysOnByDefaultOnlyInTheForeground() {
        let model = makeModel()

        #expect(model.keepsScreenAwake)
        #expect(model.keepsScreenOn(isActive: true))
        #expect(model.keepsScreenOn(isActive: false) == false)
    }

    @Test func turningScreenAlwaysOnOffIsSaved() {
        let model = makeModel()

        model.keepsScreenAwake = false

        #expect(model.keepsScreenOn(isActive: true) == false)
        #expect(LevelModel(defaults: defaults).keepsScreenAwake == false)
    }

    @Test func runReadsTheInjectedSource() async throws {
        let model = LevelModel(defaults: defaults, source: FixedGravitySource(gravity: .standing(rotatedBy: 20)))
        let task = Task { await model.run() }
        defer { task.cancel() }

        for _ in 0..<100 where model.liveReading.mode == .flat {
            try await Task.sleep(for: .milliseconds(20))
        }

        #expect(abs(model.liveReading.angle - 20) < 1e-9)
    }
}
