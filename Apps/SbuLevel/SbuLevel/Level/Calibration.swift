/// Sensor offsets measured on this iPhone: one rotation offset per edge and one for lying flat.
nonisolated struct Calibration: Equatable, Sendable {
    /// Rotation offsets in degrees, subtracted from `Gravity.rotation` when that edge rests.
    var bottom = 0.0
    var right = 0.0
    var top = 0.0
    var left = 0.0
    /// Gravity x and y the sensor reads on a level surface.
    var flatX = 0.0
    var flatY = 0.0

    /// No offsets: the sensor as it comes.
    static let none = Calibration()

    func offset(for edge: Edge) -> Double {
        switch edge {
        case .bottom: bottom
        case .right: right
        case .top: top
        case .left: left
        }
    }

    func isCalibrated(_ target: CalibrationTarget) -> Bool {
        switch target {
        case .flat: flatX != 0 || flatY != 0
        case .edge(let edge): offset(for: edge) != 0
        }
    }

    /// The sides with an offset, in settings order.
    var calibratedTargets: [CalibrationTarget] {
        CalibrationTarget.allCases.filter(isCalibrated)
    }

    /// Two-step calibration: `first` and `second` are steady readings of the same side, the second
    /// after turning the iPhone 180° on the same spot. Turning flips the slope of the surface but
    /// not the sensor's error, so their mean is the error alone, even on a surface that is not level.
    func calibrating(_ target: CalibrationTarget, first: Gravity, second: Gravity) -> Calibration {
        var result = self
        switch target {
        case .flat:
            result.flatX = (first.x + second.x) / 2
            result.flatY = (first.y + second.y) / 2
        case .edge(let edge):
            let error = (edge.deviation(of: first.rotation) + edge.deviation(of: second.rotation)) / 2
            result.setOffset(error, for: edge)
        }
        return result
    }

    /// This calibration with `target` back to the sensor as it comes.
    func resetting(_ target: CalibrationTarget) -> Calibration {
        var result = self
        switch target {
        case .flat:
            result.flatX = 0
            result.flatY = 0
        case .edge(let edge):
            result.setOffset(0, for: edge)
        }
        return result
    }

    private mutating func setOffset(_ value: Double, for edge: Edge) {
        switch edge {
        case .bottom: bottom = value
        case .right: right = value
        case .top: top = value
        case .left: left = value
        }
    }
}

extension Calibration: Codable {
    private enum CodingKeys: String, CodingKey {
        case bottom, right, top, left, flatX, flatY
        /// Version 1.0 builds saved one offset for every edge, from a one-step calibration.
        case legacyEdge = "edge"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacy = try container.decodeIfPresent(Double.self, forKey: .legacyEdge) ?? 0
        bottom = try container.decodeIfPresent(Double.self, forKey: .bottom) ?? legacy
        right = try container.decodeIfPresent(Double.self, forKey: .right) ?? legacy
        top = try container.decodeIfPresent(Double.self, forKey: .top) ?? legacy
        left = try container.decodeIfPresent(Double.self, forKey: .left) ?? legacy
        flatX = try container.decodeIfPresent(Double.self, forKey: .flatX) ?? 0
        flatY = try container.decodeIfPresent(Double.self, forKey: .flatY) ?? 0
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(right, forKey: .right)
        try container.encode(top, forKey: .top)
        try container.encode(left, forKey: .left)
        try container.encode(flatX, forKey: .flatX)
        try container.encode(flatY, forKey: .flatY)
    }
}
