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

    /// The first build's one-step calibration made a real iPhone read 9,2° flat on a table.
    @Test func aCalibrationFromTheFirstBuildIsNotApplied() {
        defaults.set(Data(#"{"flatX":-0.14916,"edge":43.0747,"flatY":-0.07201}"#.utf8), forKey: "calibration")

        let model = makeModel()
        model.update(with: Gravity(x: 0, y: 0, z: -1))

        #expect(model.isCalibrated == false)
        #expect(model.reading.displayedAngle == 0)
        #expect(model.reading.isLevel)
    }

    @Test func anImplausibleCalibrationLeavesTheSavedOneAlone() {
        let model = makeModel()
        calibrate(model, first: .standing(rotatedBy: 1), second: .standing(rotatedBy: 1))

        calibrate(model, first: .standing(rotatedBy: 8), second: .standing(rotatedBy: 6))

        #expect(model.calibrationSession?.notice == .implausible)
        #expect(abs(model.calibration.bottom - 1) < 1e-9)
        #expect(LevelModel(defaults: defaults).calibration == model.calibration)
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

    @Test func withoutASensorTheModelSaysSo() async {
        let model = LevelModel(defaults: defaults, source: NoSensorSource())

        await model.run()

        #expect(model.isMotionAvailable == false)
        #expect(model.keepsScreenOn(isActive: true))
    }

    @Test(arguments: [("flat", LevelMode.flat), ("", .edge)])
    func aLaunchCanAskForAFixedTilt(value: String, mode: LevelMode) throws {
        defaults.set(value, forKey: "FIXED_GRAVITY")
        defaults.set(true, forKey: "FASTLANE_SNAPSHOT")

        let source = try #require(FixedGravitySource.requested(in: defaults))

        #expect(LevelReading(gravity: source.gravity, calibration: .none).mode == mode)
    }

    @Test func aNormalLaunchUsesTheSensor() {
        #expect(FixedGravitySource.requested(in: defaults) == nil)
    }

    @Test func zeroHereShowsTheTurnFromThere() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))

        model.toggleReference()
        model.update(with: .standing(rotatedBy: 27))

        #expect(model.readout.isRelative)
        #expect(abs(model.readout.angle - 7) < 1e-9)
    }

    @Test func tappingAgainGoesBackToTheAbsoluteAngle() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleReference()
        model.update(with: .standing(rotatedBy: 27))

        model.toggleReference()

        #expect(model.readout.isRelative == false)
        #expect(abs(model.readout.angle - 27) < 1e-9)
    }

    @Test func changingModeClearsTheReference() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleReference()

        model.update(with: .lying(tiltedBy: 2))
        model.update(with: .standing(rotatedBy: 20))

        #expect(model.reference == nil)
        #expect(model.readout.isRelative == false)
    }

    @Test func aLockedRelativeReadingStaysFrozen() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleReference()
        model.update(with: .standing(rotatedBy: 25))

        model.toggleLock()
        model.update(with: .standing(rotatedBy: 40))
        // Rolling onto another edge while locked does not drop the reference under the frozen figure.
        model.update(with: .standing(rotatedBy: 90))

        #expect(model.readout.isRelative)
        #expect(abs(model.readout.angle - 5) < 1e-9)
    }

    @Test func zeroingWhileLockedTakesTheFrozenReading() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleLock()
        model.update(with: .standing(rotatedBy: 30))

        model.toggleReference()
        #expect(model.readout.angle == 0)
        model.toggleLock()

        #expect(abs(model.readout.angle - 10) < 1e-9)
    }

    @Test func theReferenceIsNotSaved() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleReference()

        #expect(makeModel().reference == nil)
    }

    @Test func theSightMeasuresTheLineOfSightAndEndsLockAndReference() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 20))
        model.toggleReference()
        model.toggleLock()

        model.toggleSight()
        model.update(with: Gravity(x: 0, y: -cos(.pi / 18), z: sin(.pi / 18)))

        #expect(model.isSighting)
        #expect(model.isLocked == false)
        #expect(model.reference == nil)
        #expect(model.reading.mode == .sight)
        #expect(abs(model.readout.angle - 10) < 1e-9)
    }

    @Test func calibratingClosesTheSight() {
        let model = makeModel()
        model.toggleSight()

        model.startCalibration()

        #expect(model.isSighting == false)
    }

    @Test func theSightIsNotSaved() {
        makeModel().toggleSight()

        #expect(makeModel().isSighting == false)
    }

    @Test func theUnitIsDegreesUntilChosenAndThenSaved() {
        let model = makeModel()
        #expect(model.unit == .degrees)

        model.unit = .pitch

        #expect(makeModel().unit == .pitch)
    }

    @Test func theFigureFollowsTheUnit() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 45))

        model.unit = .percent

        #expect(model.readout.unit == .percent)
        #expect(model.readout.unit.value(forDegrees: model.readout.angle) == 100)
    }
}

/// A source with no motion sensor, like the simulator.
private struct NoSensorSource: GravitySource {
    var isAvailable: Bool { false }

    func gravityUpdates() -> AsyncStream<Gravity> {
        AsyncStream { $0.finish() }
    }

    func stop() {}
}
