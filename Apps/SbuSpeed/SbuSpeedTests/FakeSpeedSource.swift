@testable import SbuSpeed

/// Plays a fixed list of events, then finishes, as if the screen had closed.
final class FakeSpeedSource: SpeedSource {
    private let scripted: [SpeedEvent]
    private(set) var isStopped = false

    init(_ scripted: [SpeedEvent]) {
        self.scripted = scripted
    }

    func events() -> AsyncStream<SpeedEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: SpeedEvent.self)
        for event in scripted {
            continuation.yield(event)
        }
        continuation.finish()
        return stream
    }

    func stop() {
        isStopped = true
    }
}
