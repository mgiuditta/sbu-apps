import Foundation
import Observation

/// Live level state: the reading, the lock, the calibration and its guided flow, saved on this iPhone.
@Observable
final class LevelModel {
    private static let calibrationKey = "calibration"
    private static let keepsScreenAwakeKey = "keepsScreenAwake"
    private static let unitKey = "unit"

    /// What the screen shows: the live reading, or the one frozen by the lock.
    private(set) var reading = LevelReading.level
    /// The reading of the latest sample, even while locked.
    private(set) var liveReading = LevelReading.level
    private(set) var calibration: Calibration
    private(set) var isMotionAvailable = true
    private(set) var isLocked = false
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
        liveReading = LevelReading(gravity: sample, calibration: calibration, previous: liveReading)
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

    /// Freezes the shown reading, or lets it follow the sensor again.
    func toggleLock() {
        isLocked.toggle()
        if isLocked == false {
            reading = liveReading
        }
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

    func startCalibration() {
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
            liveReading = LevelReading(gravity: gravity, calibration: newValue, previous: liveReading)
            if isLocked == false {
                reading = liveReading
            }
        }
    }
}
