import Foundation

/// Avvisami se lo perdi, as a state machine: it alerts once when the watched device has not
/// been heard for `silenceBeforeAlert` while Sbu Find is listening, and again only after the
/// device has been heard in between.
///
/// It only counts silence while the app listens: iOS stops the scan in the background, so time
/// spent there is not silence. Back in the foreground the clock starts again.
nonisolated struct LostAlert: Equatable, Sendable {
    /// Silence that means lost: longer than the gaps of a device that slows its advertising.
    static let silenceBeforeAlert: TimeInterval = 15

    enum Phase: Equatable, Sendable {
        /// Listening, and the device was heard recently or the clock has just started.
        case watching
        /// The alert went off; waiting to hear the device again.
        case alerted
        /// The app is not listening: no silence is counted.
        case paused
    }

    private(set) var phase: Phase
    /// When listening started or resumed: silence before it does not count.
    private var listeningSince: Date
    /// The last advertisement before the alert, to tell a new one from it.
    private var lastSeenAtAlert: Date?

    init(at now: Date) {
        phase = .watching
        listeningSince = now
    }

    /// The scan stopped: the app went to the background or Bluetooth went off.
    mutating func pause() {
        phase = .paused
    }

    /// The scan is running again: silence counts from `now`.
    mutating func resume(at now: Date) {
        guard phase == .paused else { return }
        phase = .watching
        listeningSince = now
        lastSeenAtAlert = nil
    }

    /// Takes in the device's last advertisement and returns `true` exactly when the alert should go off.
    mutating func update(lastSeen: Date?, at now: Date) -> Bool {
        switch phase {
        case .paused:
            return false
        case .alerted:
            if let lastSeen, lastSeen > (lastSeenAtAlert ?? listeningSince) {
                phase = .watching
            }
            return false
        case .watching:
            let reference = max(lastSeen ?? listeningSince, listeningSince)
            guard now.timeIntervalSince(reference) > Self.silenceBeforeAlert else { return false }
            phase = .alerted
            lastSeenAtAlert = lastSeen ?? listeningSince
            return true
        }
    }
}
