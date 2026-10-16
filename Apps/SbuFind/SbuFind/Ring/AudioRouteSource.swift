/// Where the sound goes now, and when that changes: the audio session on an iPhone, fixed
/// headphones in the simulator and UI tests.
protocol AudioRouteSource {
    var outputs: [AudioOutput] { get }

    /// Yields each time the route changes, as when headphones connect or drop out.
    func routeChanges() -> AsyncStream<Void>
}
