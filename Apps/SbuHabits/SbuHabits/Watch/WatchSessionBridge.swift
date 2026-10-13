import WatchConnectivity

/// The `WCSession` delegate on both sides: it decodes what arrives into `WatchEvent`s on
/// WatchConnectivity's queue and yields them in order, for the main actor to apply one by one.
/// Only between the user's own iPhone and Apple Watch, never through a server.
nonisolated final class WatchSessionBridge: NSObject, WCSessionDelegate, Sendable {
    /// Every event, in the order WatchConnectivity delivered it: a mark then its undo stay so.
    let events: AsyncStream<WatchEvent>
    private let continuation: AsyncStream<WatchEvent>.Continuation

    override init() {
        (events, continuation) = AsyncStream.makeStream(of: WatchEvent.self)
    }

    /// Activates the default session with this bridge, where WatchConnectivity exists.
    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        guard activationState == .activated else { return }
        continuation.yield(.activated)
        // A grid that came while the app was not running waits in the received context.
        if let snapshot = WatchPayload.snapshot(from: session.receivedApplicationContext) {
            continuation.yield(.snapshot(snapshot))
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let snapshot = WatchPayload.snapshot(from: applicationContext) else { return }
        continuation.yield(.snapshot(snapshot))
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let action = WatchPayload.action(from: userInfo) else { return }
        continuation.yield(.action(action))
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard WatchPayload.isRefreshRequest(message) else { return }
        continuation.yield(.refreshRequest)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// The user switched to another Apple Watch: start again with it.
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    /// The watch app was installed, or the watch paired: it needs today's grid.
    func sessionWatchStateDidChange(_ session: WCSession) {
        continuation.yield(.activated)
    }
    #endif
}
