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

    // MARK: - Steady lock

    private func steadyModel(tolerance: Double = 0.5) -> LevelModel {
        let model = makeModel()
        model.locksWhenSteady = true
        model.steadyTolerance = tolerance
        return model
    }

    @Test func theSteadyLockIsOffByDefaultAndSaved() {
        #expect(makeModel().locksWhenSteady == false)
        #expect(makeModel().steadyTolerance == SteadyLock.defaultTolerance)

        _ = steadyModel(tolerance: 1.2)

        #expect(makeModel().locksWhenSteady)
        #expect(makeModel().steadyTolerance == 1.2)
    }

    @Test func theSteadyLockWaitsThenFreezesTheMean() {
        let model = steadyModel()
        model.update(with: .standing(rotatedBy: 20))

        model.toggleLock()
        #expect(model.isLocked == false)
        #expect(model.steadyProgress == 0)

        for index in 0..<SteadyLock.sampleCount {
            model.update(with: .standing(rotatedBy: index.isMultiple(of: 2) ? 20.2 : 19.8))
        }

        #expect(model.isLocked)
        #expect(model.steadyProgress == nil)
        #expect(model.lockCount == 1)
        #expect(abs(model.reading.angle - 20) < 0.01)

        model.update(with: .standing(rotatedBy: 35))
        #expect(abs(model.reading.angle - 20) < 0.01)
    }

    @Test func movingPastTheToleranceStartsTheWaitOver() {
        let model = steadyModel(tolerance: 0.3)
        model.toggleLock()
        for _ in 0..<(SteadyLock.sampleCount - 1) {
            model.update(with: .standing(rotatedBy: 20))
        }

        model.update(with: .standing(rotatedBy: 21))

        #expect(model.isLocked == false)
        #expect(model.steadyProgress == 0)
    }

    @Test func tappingWhileWaitingGivesUp() {
        let model = steadyModel()
        model.toggleLock()

        model.toggleLock()
        for _ in 0..<SteadyLock.sampleCount {
            model.update(with: .standing(rotatedBy: 20))
        }

        #expect(model.steadyProgress == nil)
        #expect(model.isLocked == false)
        #expect(model.lockCount == 0)
    }

    @Test func aLockByHandCountsAtOnce() {
        let model = makeModel()

        model.toggleLock()

        #expect(model.isLocked)
        #expect(model.lockCount == 1)
    }

    @Test(arguments: [(0.0, 0.1), (0.04, 0.1), (0.54, 0.5), (1.26, 1.3), (9, 3)])
    func toleranceStaysInTheRangeToATenth(value: Double, expected: Double) {
        #expect(abs(SteadyLock.clamped(value) - expected) < 1e-9)
    }

    @Test func turningTheDialReads0AtTheSidesAndIsSaved() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 0))
        #expect(model.readout.isLevel)

        model.turnDial(by: 80)

        #expect(model.dialTurn == 90)
        #expect(abs(model.readout.angle - 90) < 1e-9)
        // Level still agrees with the figure: on the bottom edge a turned dial reads 90° level.
        #expect(model.readout.isLevel)
        #expect(makeModel().dialTurn == 90)
    }

    @Test func aRightEdgeReadsZeroLevelOnATurnedDial() {
        let model = makeModel()
        model.turnDial(by: 90)

        model.update(with: .standing(rotatedBy: 90))

        #expect(abs(model.readout.angle) < 1e-9)
        #expect(model.readout.isLevel)
    }

    @Test func turningTheDialEndsTheLockAndTheReference() {
        let model = makeModel()
        model.update(with: .standing(rotatedBy: 10))
        model.toggleReference()
        model.toggleLock()

        model.turnDial(by: -90)

        #expect(model.isLocked == false)
        #expect(model.reference == nil)
    }

    @Test func zeroAtTheSidesTurnsTheDialAndBack() {
        let model = makeModel()
        #expect(model.readsZeroAtSides == false)

        model.readsZeroAtSides = true
        #expect(model.dialTurn == 90)
        #expect(makeModel().readsZeroAtSides)

        model.readsZeroAtSides = true
        #expect(model.dialTurn == 90)

        model.readsZeroAtSides = false
        #expect(model.dialTurn == 0)
    }

    @Test func aShortDragLeavesTheDial() {
        let model = makeModel()

        model.turnDial(by: 30)

        #expect(model.dialTurn == 0)
    }

    @Test func theVolumeButtonIsOffUntilChosenAndThenSaved() {
        #expect(makeModel().locksWithVolumeButton == false)

        makeModel().locksWithVolumeButton = true

        #expect(makeModel().locksWithVolumeButton)
    }

    @Test func theSoundIsOffUntilChosenAndThenSaved() {
        #expect(makeModel().playsSound == false)

        makeModel().playsSound = true

        #expect(makeModel().playsSound)
    }

    @Test func theVoiceIsOffUntilChosenAndThenSaved() {
        #expect(makeModel().speech == .off)

        makeModel().speech = .whenSettled

        #expect(makeModel().speech == .whenSettled)
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
