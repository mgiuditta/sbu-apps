import WatchConnectivity

/// Sends the grid as the session's application context: WatchConnectivity keeps only the latest
/// one and hands it to the watch app when it runs, so an old grid never arrives after a new one.
struct WatchConnectivityChannel: WatchChannel {
    func send(_ snapshot: WatchSnapshot) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        // Before activation, or with no watch app to send to, the next `.activated` sends it.
        guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled,
              let context = try? WatchPayload.context(for: snapshot) else { return }
        // ponytail: a failed update leaves the watch on the grid before; the next change sends again.
        try? session.updateApplicationContext(context)
    }
}
