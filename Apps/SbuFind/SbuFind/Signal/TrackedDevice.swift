import Foundation

/// The device on the finder: its last state, the word with hysteresis, and how long it has been silent.
nonisolated struct TrackedDevice: Equatable, Sendable {
    /// Silent for longer than this, the finder says it no longer hears the device. Devices
    /// advertise several times a second, so three seconds of silence is no longer a gap.
    static let lostAfter: TimeInterval = 3

    var device: NearbyDevice
    var warmth: Warmth
    /// Seconds since the last advertisement.
    var silence: TimeInterval

    var isLost: Bool { silence > Self.lostAfter }

    /// The silence in whole seconds, for "Non sentito da 8 s".
    var silenceDuration: Duration {
        .seconds(Int(silence.rounded(.down)))
    }
}
