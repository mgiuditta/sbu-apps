/// The edge of the iPhone that rests on the surface in clinometer mode.
nonisolated enum Edge: String, CaseIterable, Codable, Sendable {
    case bottom
    case right
    case top
    case left

    /// The device rotation, in degrees, at which this edge lies exactly level (see `Gravity.rotation`).
    var restingRotation: Double {
        switch self {
        case .bottom: 0
        case .right: 90
        case .top: -180
        case .left: -90
        }
    }

    /// Signed degrees between `rotation` and this edge lying level.
    func deviation(of rotation: Double) -> Double {
        Angles.normalized(rotation - restingRotation)
    }

    /// The edge whose level position is closest to `rotation`.
    static func nearest(to rotation: Double) -> Edge {
        let ordered = allCases.sorted { abs($0.deviation(of: rotation)) < abs($1.deviation(of: rotation)) }
        return ordered[0]
    }
}
