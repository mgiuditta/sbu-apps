@testable import SbuFind

/// A scanner the test drives by hand: it records what the model asks of it. Events sent before
/// the model starts reading wait in the stream.
final class FakeScanner: BluetoothScanner {
    private(set) var restarts = 0
    private(set) var stops = 0
    private(set) var modes: [ScanMode] = []
    private let stream: AsyncStream<ScanEvent>
    private let continuation: AsyncStream<ScanEvent>.Continuation

    init() {
        (stream, continuation) = AsyncStream.makeStream(of: ScanEvent.self)
    }

    func events() -> AsyncStream<ScanEvent> {
        stream
    }

    func send(_ event: ScanEvent) {
        continuation.yield(event)
    }

    func finish() {
        continuation.finish()
    }

    func listen(_ mode: ScanMode) {
        modes.append(mode)
    }

    func restart() {
        restarts += 1
    }

    func stop() {
        stops += 1
        continuation.finish()
    }
}
