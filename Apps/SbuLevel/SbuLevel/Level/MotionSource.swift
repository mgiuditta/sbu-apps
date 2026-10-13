import CoreMotion

/// Streams gravity from Core Motion. Device motion needs no permission and never leaves the iPhone.
final class MotionSource: GravitySource {
    /// Time between samples: 30 per second.
    static let interval = Duration.milliseconds(33)

    private let manager = CMMotionManager()

    var isAvailable: Bool { manager.isDeviceMotionAvailable }

    func gravityUpdates() -> AsyncStream<Gravity> {
        let (stream, continuation) = AsyncStream.makeStream(of: Gravity.self, bufferingPolicy: .bufferingNewest(1))
        guard manager.isDeviceMotionAvailable else {
            continuation.finish()
            return stream
        }

        manager.deviceMotionUpdateInterval = 1.0 / 30
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
