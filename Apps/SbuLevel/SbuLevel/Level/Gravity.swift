import Foundation

/// The gravity vector in device coordinates, in g: x to the right, y up, z out of the screen.
nonisolated struct Gravity: Equatable, Sendable {
    var x: Double
    var y: Double
    var z: Double

    var length: Double { (x * x + y * y + z * z).squareRoot() }

    /// Rotation of the iPhone in the screen plane, in degrees: 0 standing on its bottom edge,
    /// 90 on its right edge, -90 on its left edge, ±180 upside down.
    var rotation: Double {
        Angles.degrees(fromRadians: atan2(x, -y))
    }

    /// Degrees between the screen and horizontal: 0 lying flat, 90 standing on an edge.
    var tiltFromFlat: Double {
        guard length > 0 else { return 0 }
        return Angles.degrees(fromRadians: acos(min(1, abs(z) / length)))
    }

    /// Gravity of an iPhone standing on an edge, rotated by `degrees` in the screen plane.
    static func standing(rotatedBy degrees: Double) -> Gravity {
        let radians = Angles.radians(fromDegrees: degrees)
        return Gravity(x: sin(radians), y: -cos(radians), z: 0)
    }

    /// Gravity of an iPhone lying on its back, tilted by `degrees` around its long axis.
    static func lying(tiltedBy degrees: Double) -> Gravity {
        let radians = Angles.radians(fromDegrees: degrees)
        return Gravity(x: sin(radians), y: 0, z: -cos(radians))
    }

    /// Degrees between this vector and `other`.
    func angle(to other: Gravity) -> Double {
        let lengths = length * other.length
        guard lengths > 0 else { return 0 }
        let cosine = (x * other.x + y * other.y + z * other.z) / lengths
        return Angles.degrees(fromRadians: acos(min(1, max(-1, cosine))))
    }

    /// The average of `samples`, or `nil` when there are none.
    static func mean(of samples: [Gravity]) -> Gravity? {
        guard samples.isEmpty == false else { return nil }
        let count = Double(samples.count)
        return Gravity(
            x: samples.map(\.x).reduce(0, +) / count,
            y: samples.map(\.y).reduce(0, +) / count,
            z: samples.map(\.z).reduce(0, +) / count
        )
    }
}
