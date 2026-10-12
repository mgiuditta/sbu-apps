import CoreGraphics

/// The lit part of the moon's disc as seen from the northern hemisphere: lit on the right while
/// waxing, on the left while waning. The terminator is half an ellipse whose horizontal semi-axis
/// is `radius × (1 − 2 × illumination)`, so the lit area is exactly `illumination` of the disc.
nonisolated struct MoonDisc: Equatable, Sendable {
    /// Fraction of the disc that is lit, clamped to 0...1.
    var illumination: Double
    /// Whether the moon is going from new to full.
    var isWaxing: Bool

    init(illumination: Double, isWaxing: Bool) {
        self.illumination = min(max(illumination, 0), 1)
        self.isWaxing = isWaxing
    }

    /// Which side the bright limb is on: +1 right (waxing), −1 left (waning).
    private var litSide: Double { isWaxing ? 1 : -1 }

    /// Horizontal semi-axis of the terminator as a fraction of the radius, signed towards the lit
    /// limb: 1 at new moon (the terminator is the lit limb), 0 at a quarter, −1 at full moon.
    var terminatorSemiAxis: Double {
        litSide * (1 - 2 * illumination)
    }

    /// The outline of the lit part, clockwise in screen coordinates (y down): the lit limb from
    /// top to bottom, then the terminator back to the top.
    /// - Parameters:
    ///   - center: The centre of the disc.
    ///   - radius: The radius of the disc.
    ///   - segments: Points along each half; more is smoother.
    func litOutline(center: CGPoint, radius: CGFloat, segments: Int = 96) -> [CGPoint] {
        let steps = max(segments, 2)
        // The polar angle runs from −π/2 (top) to π/2 (bottom); x = cos, y = sin.
        let limb = (0...steps).map { step -> CGPoint in
            let angle = -Double.pi / 2 + Double.pi * Double(step) / Double(steps)
            return CGPoint(
                x: center.x + radius * litSide * cos(angle),
                y: center.y + radius * sin(angle)
            )
        }
        let terminator = (1..<steps).reversed().map { step -> CGPoint in
            let angle = -Double.pi / 2 + Double.pi * Double(step) / Double(steps)
            return CGPoint(
                x: center.x + radius * terminatorSemiAxis * cos(angle),
                y: center.y + radius * sin(angle)
            )
        }
        return limb + terminator
    }
}
