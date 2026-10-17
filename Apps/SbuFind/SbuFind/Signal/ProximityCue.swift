import Foundation

/// The rhythm of the ticks on the finder: slow when the device sounds far, fast when it is close,
/// like a Geiger counter. Silent while the device is not heard.
nonisolated enum ProximityCue {
    /// The gap between two ticks at proximity 0.
    static let slowest = Duration.milliseconds(1500)
    /// The gap between two ticks at proximity 100.
    static let fastest = Duration.milliseconds(150)

    /// The gap before the next tick, shrinking linearly as the proximity grows.
    static func interval(for proximity: Proximity) -> Duration {
        let fraction = Double(proximity.value) / 100
        return slowest - (slowest - fastest) * fraction
    }

    /// Whether a tick plays at all: only with a switch on and the device still heard.
    static func shouldTick(tracked: TrackedDevice?, playsSound: Bool, vibrates: Bool) -> Bool {
        guard let tracked, playsSound || vibrates else { return false }
        return !tracked.isLost
    }
}
