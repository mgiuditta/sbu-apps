import Foundation

/// How close a device sounds, from 0 (barely heard) to 100 (touching the iPhone).
///
/// A scale of our own over the signal strength, not a distance: the same reading means a
/// different distance for every chip, through a pocket, a wall or a sofa.
///
/// Pending decision #214 (percentage, dBm or a word): a 0-100 figure without a % sign, the
/// option closest to Find Air's percentage, with the word beside it.
nonisolated struct Proximity: Equatable, Comparable, Sendable {
    /// At or below this the figure is 0: the edge of what an iPhone hears.
    static let farthestRSSI = -100.0
    /// At or above this the figure is 100: the device is on the iPhone.
    static let nearestRSSI = -40.0

    /// From 0 to 100.
    let value: Int

    /// - Parameter rssi: The signal in dBm, raw or filtered.
    init(rssi: Double) {
        let fraction = (rssi - Self.farthestRSSI) / (Self.nearestRSSI - Self.farthestRSSI)
        // Not a number would trap in Int(_:): it reads as not heard.
        let clamped = fraction.isNaN ? 0 : min(max(fraction, 0), 1)
        value = Int((clamped * 100).rounded())
    }

    init(rssi: Int) {
        self.init(rssi: Double(rssi))
    }

    static func < (lhs: Proximity, rhs: Proximity) -> Bool {
        lhs.value < rhs.value
    }
}
