@testable import SbuFind

extension Proximity {
    /// A proximity with an exact value, for tests at the thresholds.
    init(value: Int) {
        self.init(rssi: Proximity.farthestRSSI + Double(value) / 100 * (Proximity.nearestRSSI - Proximity.farthestRSSI))
    }
}
