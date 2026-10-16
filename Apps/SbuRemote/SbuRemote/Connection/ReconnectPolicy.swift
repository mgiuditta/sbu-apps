/// When the remote reconnects on its own, with the saved credential and no pairing.
nonisolated enum ReconnectPolicy {
    enum Event: Equatable, Sendable {
        /// The app came back to the foreground.
        case becameActive
        /// The app went to the background.
        case wentToBackground
        /// The Wi-Fi changed: a new network, or the same one back.
        case networkChanged(isOnLocalNetwork: Bool)
        /// The TV closed the connection by itself.
        case dropped
    }

    enum Action: Equatable, Sendable {
        case reconnect
        case disconnect
        case nothing
    }

    static func action(for event: Event, status: ConnectionStatus) -> Action {
        guard status != .noTV else { return .nothing }
        switch event {
        case .becameActive, .dropped:
            // A TV that forgot the phone needs pairing again, not a retry loop.
            return status == .connected || status == .connecting || status == .notPaired ? .nothing : .reconnect
        case .wentToBackground:
            // No socket kept open behind the user's back: it costs battery and the TV pings it.
            return .disconnect
        case .networkChanged(let isOnLocalNetwork):
            guard isOnLocalNetwork else { return .disconnect }
            return status == .connecting || status == .notPaired ? .nothing : .reconnect
        }
    }
}
