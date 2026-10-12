import Foundation
import Observation

/// Live level state: the latest reading and a calibration saved on this iPhone.
@Observable
final class LevelModel {
    private static let calibrationKey = "calibration"

    private(set) var reading = LevelReading.level
    private(set) var calibration: Calibration
    private(set) var isMotionAvailable = true

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let motion = MotionSource()
    @ObservationIgnored private var gravity: Gravity?

    var isCalibrated: Bool { calibration != .none }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        calibration = defaults.data(forKey: Self.calibrationKey)
            .flatMap { try? JSONDecoder().decode(Calibration.self, from: $0) } ?? .none
    }

    /// Reads the sensor until the calling task is cancelled.
    func run() async {
        // fastlane snapshot runs in the simulator, which has no motion sensor: show a fixed tilt.
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") {
            update(with: Gravity(x: sin(2.4 * .pi / 180), y: 0, z: -cos(2.4 * .pi / 180)))
            return
        }
        isMotionAvailable = motion.isAvailable
        for await sample in motion.gravityUpdates() {
            update(with: sample)
        }
        motion.stop()
    }

    func update(with sample: Gravity) {
        gravity = sample
        reading = LevelReading(gravity: sample, calibration: calibration)
    }

    /// Makes the current position read 0° in the current mode.
    func calibrate() {
        guard let gravity else { return }
        save(calibration.levelling(gravity))
    }

    func resetCalibration() {
        save(.none)
    }

    private func save(_ newValue: Calibration) {
        calibration = newValue
        // ponytail: try? is safe here, encoding three Doubles cannot fail.
        defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.calibrationKey)
        if let gravity {
            reading = LevelReading(gravity: gravity, calibration: newValue)
        }
    }
}
