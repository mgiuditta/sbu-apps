import Foundation

/// A steady gravity vector at the motion rate, for the simulator, screenshots, UI tests and previews.
/// The simulator has no motion sensor.
struct FixedGravitySource: GravitySource {
    /// The iPhone standing on its bottom edge on a 32,4° slope: the App Store screenshot.
    static let screenshot = FixedGravitySource(gravity: .standing(rotatedBy: 32.4))
    /// The iPhone lying on a surface tilted about 3,3° down to the right and towards you.
    static let flat = FixedGravitySource(gravity: Gravity(x: 0.05, y: -0.03, z: -0.998))

    /// The iPhone on its bottom edge, 0,6° off: a surface a calibration accepts.
    static let nearlyLevel = FixedGravitySource(gravity: .standing(rotatedBy: 0.6))

    /// The fixed source a launch asks for: `-FASTLANE_SNAPSHOT YES` for the screenshot tilt,
    /// `-FIXED_GRAVITY flat` for the bubble, `-FIXED_GRAVITY nearlyLevel` for a calibration.
    /// `nil` on a normal launch.
    static func requested(in defaults: UserDefaults) -> FixedGravitySource? {
        switch defaults.string(forKey: "FIXED_GRAVITY") {
        case "flat": flat
        case "nearlyLevel": nearlyLevel
        default: defaults.bool(forKey: "FASTLANE_SNAPSHOT") ? screenshot : nil
        }
    }

    let gravity: Gravity

    var isAvailable: Bool { true }

    func gravityUpdates() -> AsyncStream<Gravity> {
        let gravity = gravity
        return AsyncStream {
            try? await Task.sleep(for: MotionSource.interval)
            return Task.isCancelled ? nil : gravity
        }
    }

    func stop() {}
}
