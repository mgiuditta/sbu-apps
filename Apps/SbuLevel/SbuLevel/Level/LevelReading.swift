import Foundation

/// What the level shows for one gravity sample: mode, angle and bubble position.
nonisolated struct LevelReading: Equatable, Sendable {
    /// Below this angle the iPhone counts as level: it is what rounds to "0,0" at one decimal.
    static let levelTolerance = 0.05
    /// Tilt at which the bubble reaches the edge of its circle.
    static let bubbleRange = 10.0

    /// A level iPhone lying flat.
    static let level = LevelReading(mode: .flat, angle: 0, bubbleX: 0, bubbleY: 0)

    var mode: LevelMode
    /// Signed angle in degrees: tilt from horizontal (flat) or from the nearest right angle (edge).
    var angle: Double
    /// Bubble offset in -1...1, screen axes (x right, y down). Zero in edge mode.
    var bubbleX: Double
    var bubbleY: Double

    /// The angle shown to the user, never negative.
    var magnitude: Double { abs(angle) }

    var isLevel: Bool { magnitude < Self.levelTolerance }

    init(mode: LevelMode, angle: Double, bubbleX: Double, bubbleY: Double) {
        self.mode = mode
        self.angle = angle
        self.bubbleX = bubbleX
        self.bubbleY = bubbleY
    }

    /// Creates the reading for a gravity sample with a calibration applied.
    init(gravity: Gravity, calibration: Calibration) {
        switch Self.mode(for: gravity) {
        case .flat:
            let x = gravity.x - calibration.flatX
            let y = gravity.y - calibration.flatY
            let range = sin(Self.bubbleRange * .pi / 180)
            // The bubble floats to the high side, away from gravity.
            self.init(
                mode: .flat,
                angle: asin(min(1, (x * x + y * y).squareRoot())) * 180 / .pi,
                bubbleX: Self.clamped(-x / range),
                bubbleY: Self.clamped(y / range)
            )
        case .edge:
            self.init(
                mode: .edge,
                angle: Self.wrapped(Self.edgeDeviation(for: gravity) - calibration.edge),
                bubbleX: 0,
                bubbleY: 0
            )
        }
    }

    /// Flat when the screen faces up or down within 45°.
    static func mode(for gravity: Gravity) -> LevelMode {
        abs(gravity.z) >= (0.5).squareRoot() ? .flat : .edge
    }

    /// Angle in degrees between the iPhone's edges and the nearest horizontal or vertical.
    static func edgeDeviation(for gravity: Gravity) -> Double {
        let rotation = atan2(gravity.x, -gravity.y) * 180 / .pi
        return wrapped(rotation)
    }

    /// Folds an angle into -45..<45 around the nearest right angle.
    private static func wrapped(_ degrees: Double) -> Double {
        degrees - 90 * (degrees / 90).rounded()
    }

    private static func clamped(_ value: Double) -> Double {
        min(1, max(-1, value))
    }
}
