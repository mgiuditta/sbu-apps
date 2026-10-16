import Foundation

/// The first seconds of a scan, when an empty list only means nothing has been heard yet: the
/// header's spinner says so, and "Nessun dispositivo vicino" waits until they are over.
nonisolated struct ScanWindow: Equatable, Sendable {
    /// Seconds a scan needs before an empty list means there is nothing nearby.
    static let settling: TimeInterval = 4

    private(set) var startedAt: Date?

    /// A scan starts: at launch, when Bluetooth comes back, or with Cerca di nuovo.
    mutating func start(at now: Date) {
        startedAt = now
    }

    /// Whether the scan is still in its first seconds; a scan never started is not settling.
    func isSettling(at now: Date) -> Bool {
        guard let startedAt else { return false }
        return now.timeIntervalSince(startedAt) < Self.settling
    }
}
