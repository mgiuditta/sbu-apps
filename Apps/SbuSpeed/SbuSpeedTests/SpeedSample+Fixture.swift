import Foundation
@testable import SbuSpeed

extension SpeedSample {
    /// A precise fix `seconds` after a fixed start, `metersNorth` north of a point in Milan.
    static func fix(
        at seconds: TimeInterval,
        metersNorth: Double = 0,
        speed: Double,
        speedAccuracy: Double = 0.5,
        horizontalAccuracy: Double = 5
    ) -> SpeedSample {
        // Core Location measures on a sphere: one degree of latitude is about 111.2 km.
        SpeedSample(
            timestamp: Date(timeIntervalSinceReferenceDate: 800_000_000 + seconds),
            speed: speed,
            speedAccuracy: speedAccuracy,
            latitude: 45.4642 + metersNorth / 111_195,
            longitude: 9.19,
            horizontalAccuracy: horizontalAccuracy
        )
    }
}
