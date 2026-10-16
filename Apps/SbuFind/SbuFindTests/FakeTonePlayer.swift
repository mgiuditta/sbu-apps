@testable import SbuFind

/// Records the plays and lets the test finish the tone or make it fail.
final class FakeTonePlayer: TonePlayer {
    struct Refused: Error {}

    var fails = false
    private(set) var plays = 0
    private(set) var stops = 0
    private(set) var lastSampleCount = 0
    private var finished: (@MainActor () -> Void)?

    func play(_ samples: [Float], sampleRate: Double, finished: @escaping @MainActor () -> Void) throws {
        if fails { throw Refused() }
        plays += 1
        lastSampleCount = samples.count
        self.finished = finished
    }

    func stop() {
        stops += 1
    }

    func finish() {
        finished?()
    }
}
