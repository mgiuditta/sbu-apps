import Foundation

/// Asks for a position in the background at most once a minute per device: each fix costs battery,
/// and a device heard again seconds later has not moved anywhere worth saving.
nonisolated struct PlaceThrottle: Equatable, Sendable {
    static let interval: TimeInterval = 60

    private var lastAsked: [UUID: Date] = [:]

    /// Whether to ask for a fix for `deviceID` now; asking records the time.
    mutating func shouldAsk(for deviceID: UUID, at now: Date) -> Bool {
        if let last = lastAsked[deviceID], now.timeIntervalSince(last) < Self.interval {
            return false
        }
        lastAsked[deviceID] = now
        return true
    }
}
