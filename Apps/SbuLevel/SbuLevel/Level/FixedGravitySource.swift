/// A steady gravity vector at the motion rate, for the simulator, screenshots, UI tests and previews.
/// The simulator has no motion sensor.
struct FixedGravitySource: GravitySource {
    /// The iPhone standing on its bottom edge on a 32,4° slope: the App Store screenshot.
    static let screenshot = FixedGravitySource(gravity: .standing(rotatedBy: 32.4))

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
