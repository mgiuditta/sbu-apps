/// Headphones that stay connected and a player that stays silent: for the simulator's fixed
/// scanner, UI tests and previews.
final class FixedAudio: AudioRouteSource, TonePlayer {
    var outputs: [AudioOutput]
    private(set) var isPlaying = false

    init(outputs: [AudioOutput] = [AudioOutput(kind: .bluetooth, name: "Buds Pro")]) {
        self.outputs = outputs
    }

    func routeChanges() -> AsyncStream<Void> {
        AsyncStream { _ in }
    }

    func play(_ samples: [Float], sampleRate: Double, finished: @escaping @MainActor () -> Void) throws {
        isPlaying = true
    }

    func stop() {
        isPlaying = false
    }
}
