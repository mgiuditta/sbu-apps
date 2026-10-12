import CoreMotion

/// Streams gravity from Core Motion. Device motion needs no permission and never leaves the iPhone.
final class MotionSource {
    private static let updatesPerSecond = 30.0

    private let manager = CMMotionManager()

    var isAvailable: Bool { manager.isDeviceMotionAvailable }

    /// Starts device motion and yields the newest gravity sample; finishes at once without a sensor.
    /// Call `stop()` when the consumer is done.
    func gravityUpdates() -> AsyncStream<Gravity> {
        let (stream, continuation) = AsyncStream.makeStream(of: Gravity.self, bufferingPolicy: .bufferingNewest(1))
        guard manager.isDeviceMotionAvailable else {
            continuation.finish()
            return stream
        }

        manager.deviceMotionUpdateInterval = 1 / Self.updatesPerSecond
        manager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let gravity = motion?.gravity else { return }
            continuation.yield(Gravity(x: gravity.x, y: gravity.y, z: gravity.z))
        }
        return stream
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
