/// Something that streams gravity samples: Core Motion on a device, a fixed vector in the simulator.
protocol GravitySource {
    var isAvailable: Bool { get }

    /// Yields the newest gravity sample; finishes at once without a sensor. Call `stop()` when done.
    func gravityUpdates() -> AsyncStream<Gravity>

    func stop()
}
