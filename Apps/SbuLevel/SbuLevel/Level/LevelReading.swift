import Foundation

/// What the level shows for one gravity sample: mode, resting edge and angle.
nonisolated struct LevelReading: Equatable, Sendable {
    /// Tilt from flat, in degrees, where lying flat turns into standing on an edge.
    static let modeThreshold = 45.0
    /// How far past a threshold the current mode or edge holds, so the view does not flicker on it.
    static let hysteresis = 5.0

    /// A level iPhone lying flat.
    static let level = LevelReading(mode: .flat, edge: nil, angle: 0, deviation: 0, rotation: 0)

    var mode: LevelMode
    /// The edge resting on the surface; `nil` when flat.
    var edge: Edge?
    /// The angle shown, 0...90. Flat: tilt from horizontal. Edge: the dial reading, 0° when the
    /// bottom or top edge is level and 90° when a side edge is. Sight: the elevation of the line of
    /// sight, -90...90, negative below the horizon.
    var angle: Double
    /// Signed degrees from level: of the surface when flat, of the resting edge when standing.
    var deviation: Double
    /// Calibrated device rotation in degrees (see `Gravity.rotation`); zero when flat. In sight, the
    /// roll that tilts the horizon.
    var rotation: Double
    /// The dial's turn the angle was read on: 0, or 90 with 0° at the sides (see `DialGeometry`).
    var dialTurn = 0.0

    /// The angle as shown: rounded half away from zero to a tenth, never negative, so it reads
    /// "0,0" and never "-0,0". The figure formats exactly this value.
    var displayedAngle: Double {
        abs((angle * 10).rounded(.toNearestOrAwayFromZero) / 10)
    }

    /// The angle the figure shows when the iPhone is level: 90° on a side edge, 0° otherwise, or
    /// the other way round on a turned dial.
    var levelAngle: Double {
        guard let edge else { return 0 }
        return DialGeometry.value(at: DialGeometry.needlePosition(rotation: edge.restingRotation), dialTurn: dialTurn)
    }

    /// Level when the figure shows the level angle: "In bolla" and the figure always agree.
    var isLevel: Bool { displayedAngle == levelAngle }

    /// What a calibration of this position would set.
    var calibrationTarget: CalibrationTarget {
        edge.map(CalibrationTarget.edge) ?? .flat
    }

    init(
        mode: LevelMode,
        edge: Edge?,
        angle: Double,
        deviation: Double,
        rotation: Double
    ) {
        self.mode = mode
        self.edge = edge
        self.angle = angle
        self.deviation = deviation
        self.rotation = rotation
    }

    /// Creates the reading for a gravity sample with a calibration applied.
    /// - Parameters:
    ///   - previous: The reading before this one; its mode and edge hold near the thresholds.
    ///   - dialTurn: The dial's turn, 0 or 90, for the edge angle.
    init(gravity: Gravity, calibration: Calibration, previous: LevelReading? = nil, dialTurn: Double = 0) {
        switch Self.mode(for: gravity, previous: previous?.mode) {
        case .flat:
            let x = gravity.x - calibration.flatX
            let y = gravity.y - calibration.flatY
            let tilt = Angles.degrees(fromRadians: asin(min(1, (x * x + y * y).squareRoot())))
            self.init(
                mode: .flat,
                edge: nil,
                angle: tilt,
                deviation: tilt,
                rotation: 0
            )
        case .edge, .sight:
            let edge = Self.edge(for: gravity.rotation, previous: previous?.edge)
            let rotation = Angles.normalized(gravity.rotation - calibration.offset(for: edge))
            self.init(
                mode: .edge,
                edge: edge,
                angle: DialGeometry.value(at: DialGeometry.needlePosition(rotation: rotation), dialTurn: dialTurn),
                deviation: edge.deviation(of: rotation),
                rotation: rotation
            )
            self.dialTurn = dialTurn
        }
    }

    /// The reading through the camera sight. The flat calibration corrects it: it measures how
    /// the sensor sits in the iPhone, and so the tilt of the line of sight too.
    static func sight(gravity: Gravity, calibration: Calibration) -> LevelReading {
        let flatZ = -max(0, 1 - calibration.flatX * calibration.flatX - calibration.flatY * calibration.flatY).squareRoot()
        let corrected = gravity.correcting(level: Gravity(x: calibration.flatX, y: calibration.flatY, z: flatZ))
        let elevation = corrected.elevation
        return LevelReading(
            mode: .sight,
            edge: nil,
            angle: elevation,
            deviation: elevation,
            rotation: corrected.rotation
        )
    }

    /// Flat when the screen faces up or down within 45°; past that, the previous mode holds for 5° more.
    static func mode(for gravity: Gravity, previous: LevelMode? = nil) -> LevelMode {
        let threshold = switch previous {
        case .flat: modeThreshold + hysteresis
        case .edge: modeThreshold - hysteresis
        case .sight, nil: modeThreshold
        }
        return gravity.tiltFromFlat < threshold ? .flat : .edge
    }

    /// The edge closest to level; the previous edge holds until it is 50° away from level.
    static func edge(for rotation: Double, previous: Edge? = nil) -> Edge {
        if let previous, abs(previous.deviation(of: rotation)) <= 45 + hysteresis {
            return previous
        }
        return Edge.nearest(to: rotation)
    }
}
