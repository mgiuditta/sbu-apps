import Foundation

/// Helpers for angles in degrees.
nonisolated enum Angles {
    /// Folds any angle into -180..<180.
    static func normalized(_ degrees: Double) -> Double {
        let folded = (degrees + 180).truncatingRemainder(dividingBy: 360)
        return (folded < 0 ? folded + 360 : folded) - 180
    }

    static func degrees(fromRadians radians: Double) -> Double {
        radians * 180 / .pi
    }

    static func radians(fromDegrees degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
