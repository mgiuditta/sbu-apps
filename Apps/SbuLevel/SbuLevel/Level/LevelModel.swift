import Foundation
import Observation

/// Live level state: the reading, the lock, the calibration and its guided flow, saved on this iPhone.
@Observable
final class LevelModel {
    private static let calibrationKey = "calibration"
    private static let keepsScreenAwakeKey = "keepsScreenAwake"
    private static let unitKey = "unit"
    private static let locksWhenSteadyKey = "locksWhenSteady"
    private static let steadyToleranceKey = "steadyTolerance"
    private static let speechKey = "speech"
    private static let playsSoundKey = "playsSound"
    private static let locksWithVolumeButtonKey = "locksWithVolumeButton"
    private static let dialTurnKey = "dialTurn"

    /// What the screen shows: the live reading, or the one frozen by the lock.
    private(set) var reading = LevelReading.level
    /// The reading of the latest sample, even while locked.
    private(set) var liveReading = LevelReading.level
    private(set) var calibration: Calibration
    private(set) var isMotionAvailable = true
    private(set) var isLocked = false
    /// Progress, 0..<1, of the wait for a steady reading after Blocca; `nil` when not waiting.
    private(set) var steadyProgress: Double?
    /// Counts the locks made, by hand or once the reading held still: a change means a new
    /// figure was just captured.
    private(set) var lockCount = 0
    /// Whether the camera sight is on: the figure is then the elevation of the line of sight.
    /// Never saved: the app opens on the level.
    private(set) var isSighting = false
    /// The reading "Azzera qui" took as zero. Never saved: it ends with the app, with "Assoluto",
    /// or when the iPhone changes mode or edge.
    private(set) var reference: LevelReading?
    /// The two-step calibration in progress, if any.
    private(set) var calibrationSession: CalibrationSession?

    /// Keeps the screen on while the tool screen is in the foreground. On by default.
    var keepsScreenAwake: Bool {
        didSet { defaults.set(keepsScreenAwake, forKey: Self.keepsScreenAwakeKey) }
    }

    /// How the figure reads the angle. Degrees to the tenth by default.
    var unit: AngleUnit {
        didSet { defaults.set(unit.rawValue, forKey: Self.unitKey) }
    }

    /// After Blocca, wait for the reading to hold still, then freeze the average. Off by default.
    var locksWhenSteady: Bool {
        didSet { defaults.set(locksWhenSteady, forKey: Self.locksWhenSteadyKey) }
    }

    /// How far, in degrees either way, the reading may move while the steady lock waits.
    var steadyTolerance: Double {
        didSet { defaults.set(steadyTolerance, forKey: Self.steadyToleranceKey) }
    }

    /// When the iPhone reads the figure aloud. Off by default.
    var speech: SpeechMode {
        didSet { defaults.set(speech.rawValue, forKey: Self.speechKey) }
    }

    /// Plays a short sound when a lock or a calibration step is captured. Off by default.
    var playsSound: Bool {
        didSet { defaults.set(playsSound, forKey: Self.playsSoundKey) }
    }

    /// In the sight, a volume button presses Blocca. Off by default.
    var locksWithVolumeButton: Bool {
        didSet { defaults.set(locksWithVolumeButton, forKey: Self.locksWithVolumeButtonKey) }
    }

    /// The dial's turn: 0 reads 0° on the bottom and top edges, 90 reads 0° on the sides. Saved.
    private(set) var dialTurn: Double

    @ObservationIgnored private var steadySampler: StableSampler?
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let source: any GravitySource
    @ObservationIgnored private var gravity: Gravity?

    var isCalibrated: Bool { calibration != .none }

    /// What the figure says for the shown reading.
    var readout: Readout { Readout(reading: reading, unit: unit, reference: reference) }

    /// - Parameters:
    ///   - defaults: Where the calibration and settings are saved.
    ///   - source: The gravity stream; by default Core Motion, or a fixed tilt for `fastlane snapshot`
    ///     and UI tests, which run in the simulator without a motion sensor.
    init(defaults: UserDefaults = .standard, source: (any GravitySource)? = nil) {
        self.defaults = defaults
        if let source {
            self.source = source
        } else if let fixed = FixedGravitySource.requested(in: defaults) {
            self.source = fixed
        } else {
            self.source = MotionSource()
        }
        calibration = defaults.data(forKey: Self.calibrationKey)
            .flatMap { try? JSONDecoder().decode(Calibration.self, from: $0) } ?? .none
        keepsScreenAwake = defaults.object(forKey: Self.keepsScreenAwakeKey) as? Bool ?? true
        unit = defaults.string(forKey: Self.unitKey).flatMap(AngleUnit.init(rawValue:)) ?? .standard
        locksWhenSteady = defaults.bool(forKey: Self.locksWhenSteadyKey)
        playsSound = defaults.bool(forKey: Self.playsSoundKey)
        locksWithVolumeButton = defaults.bool(forKey: Self.locksWithVolumeButtonKey)
        dialTurn = defaults.double(forKey: Self.dialTurnKey) == DialGeometry.quarterTurn ? DialGeometry.quarterTurn : 0
        speech = defaults.string(forKey: Self.speechKey).flatMap(SpeechMode.init(rawValue:)) ?? .off
        steadyTolerance = SteadyLock.clamped(defaults.object(forKey: Self.steadyToleranceKey) as? Double ?? SteadyLock.defaultTolerance)
    }

    /// Reads the sensor until the calling task is cancelled.
    func run() async {
        isMotionAvailable = source.isAvailable
        for await sample in source.gravityUpdates() {
            update(with: sample)
        }
        source.stop()
    }

    func update(with sample: Gravity) {
        gravity = sample
        liveReading = makeReading(for: sample, calibration: calibration)
        if var sampler = steadySampler {
            switch sampler.add(sample) {
            case .collecting(let progress):
                steadyProgress = progress
            case .moved:
                steadyProgress = 0
            case .stable(let mean):
                finishSteadyLock(with: mean)
            }
            // Still waiting: keep the samples. Finished: the sampler is gone.
            if steadyProgress != nil {
                steadySampler = sampler
            }
        }
        if isLocked == false {
            reading = liveReading
            // A reference from another mode or edge would compare two different angles.
            if let reference, Readout.applies(reference, to: reading) == false {
                self.reference = nil
            }
        }
        if var session = calibrationSession {
            session.add(sample, on: liveReading.calibrationTarget, base: calibration)
            calibrationSession = session
            if let result = session.result, result != calibration {
                save(result)
            }
        }
    }

    private func makeReading(for sample: Gravity, calibration: Calibration) -> LevelReading {
        isSighting
            ? .sight(gravity: sample, calibration: calibration)
            : LevelReading(gravity: sample, calibration: calibration, previous: liveReading, dialTurn: dialTurn)
    }

    /// Turns the camera sight on or off. The lock and the reference belong to the other mode, so
    /// both end.
    func toggleSight() {
        isSighting.toggle()
        isLocked = false
        cancelSteadyLock()
        reference = nil
        liveReading = gravity.map { makeReading(for: $0, calibration: calibration) } ?? .level
        reading = liveReading
    }

    /// Freezes the shown reading, or lets it follow the sensor again. With `locksWhenSteady`, it
    /// first waits for the reading to hold still; tapping again while waiting gives up.
    func toggleLock() {
        if isLocked {
            isLocked = false
            reading = liveReading
        } else if steadyProgress != nil {
            cancelSteadyLock()
        } else if locksWhenSteady {
            steadySampler = SteadyLock.sampler(tolerance: steadyTolerance)
            steadyProgress = 0
        } else {
            isLocked = true
            lockCount += 1
        }
    }

    private func finishSteadyLock(with mean: Gravity) {
        cancelSteadyLock()
        liveReading = makeReading(for: mean, calibration: calibration)
        reading = liveReading
        isLocked = true
        lockCount += 1
    }

    private func cancelSteadyLock() {
        steadySampler = nil
        steadyProgress = nil
    }

    /// Turns the dial after a drag of `degrees`, snapping to a quarter, and saves it. The reference
    /// and a locked figure were read on the old dial, so both end.
    func turnDial(by degrees: Double) {
        let turned = DialGeometry.turn(dialTurn, draggedBy: degrees)
        guard turned != dialTurn else { return }
        dialTurn = turned
        defaults.set(turned, forKey: Self.dialTurnKey)
        isLocked = false
        cancelSteadyLock()
        reference = nil
        if let gravity {
            liveReading = makeReading(for: gravity, calibration: calibration)
        }
        reading = liveReading
    }

    /// Takes the shown reading as zero, or goes back to the absolute angle. While locked, the
    /// frozen reading is the zero.
    func toggleReference() {
        reference = readout.isRelative ? nil : reading
    }

    /// Whether the screen should stay on, given whether the app is in the foreground.
    func keepsScreenOn(isActive: Bool) -> Bool {
        keepsScreenAwake && isActive
    }

    // MARK: - Calibration

    /// Starts calibrating the side the iPhone rests on; the sight closes, since it rests on none.
    func startCalibration() {
        if isSighting { toggleSight() }
        calibrationSession = CalibrationSession()
    }

    /// Measures the current step of the calibration.
    func captureCalibrationStep() {
        calibrationSession?.startCapture()
    }

    /// Closes the calibration; a finished one is already saved.
    func endCalibration() {
        calibrationSession = nil
    }

    /// Puts one side, or every side with `nil`, back to the sensor as it comes.
    func resetCalibration(_ target: CalibrationTarget? = nil) {
        save(target.map(calibration.resetting) ?? .none)
    }

    private func save(_ newValue: Calibration) {
        calibration = newValue
        // ponytail: try? is safe here, encoding six Doubles cannot fail.
        defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.calibrationKey)
        if let gravity {
            liveReading = makeReading(for: gravity, calibration: newValue)
            if isLocked == false {
                reading = liveReading
            }
        }
    }
}
