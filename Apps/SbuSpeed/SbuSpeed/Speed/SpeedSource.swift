/// Where the speed comes from: Core Location in the app, a fixed list in tests.
protocol SpeedSource {
    /// Starts reading and yields access changes and fixes. Call `stop()` when the consumer is done.
    func events() -> AsyncStream<SpeedEvent>

    func stop()
}
