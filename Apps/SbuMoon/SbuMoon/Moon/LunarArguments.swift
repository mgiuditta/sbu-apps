import Foundation

/// The fundamental arguments of the moon's motion at an instant, in degrees (Meeus 47.2–47.6).
nonisolated struct LunarArguments: Equatable, Sendable {
    /// Moon's mean elongation, D.
    var elongation: Double
    /// Sun's mean anomaly, M.
    var sunAnomaly: Double
    /// Moon's mean anomaly, M′.
    var moonAnomaly: Double
    /// Moon's argument of latitude, F.
    var latitude: Double
    /// Eccentricity factor of the Earth's orbit, E (47.6).
    var eccentricity: Double

    /// The arguments at `t` Julian centuries of Terrestrial Time from J2000.0.
    init(julianCenturies t: Double) {
        let t2 = t * t, t3 = t2 * t, t4 = t3 * t
        elongation = 297.8501921 + 445_267.1114034 * t - 0.0018819 * t2 + t3 / 545_868 - t4 / 113_065_000
        sunAnomaly = 357.5291092 + 35_999.0502909 * t - 0.0001536 * t2 + t3 / 24_490_000
        moonAnomaly = 134.9633964 + 477_198.8675055 * t + 0.0087414 * t2 + t3 / 69_699 - t4 / 14_712_000
        latitude = 93.2720950 + 483_202.0175233 * t - 0.0036539 * t2 - t3 / 3_526_000 + t4 / 863_310_000
        eccentricity = 1 - 0.002516 * t - 0.0000074 * t2
    }
}
