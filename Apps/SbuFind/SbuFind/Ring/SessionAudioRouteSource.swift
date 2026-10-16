import AVFoundation

/// The audio session's current route, and its changes from the system notification.
struct SessionAudioRouteSource: AudioRouteSource {
    var outputs: [AudioOutput] {
        AVAudioSession.sharedInstance().currentRoute.outputs.map { AudioOutput(port: $0.portType, name: $0.portName) }
    }

    func routeChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                for await _ in NotificationCenter.default.notifications(named: AVAudioSession.routeChangeNotification) {
                    continuation.yield()
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
