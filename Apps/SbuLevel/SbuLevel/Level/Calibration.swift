import Foundation

/// Sensor offsets measured on this iPhone: one rotation offset per edge and one for lying flat.
nonisolated struct Calibration: Equatable, Sendable {
    /// The largest sensor error, in degrees, a calibration may correct. A real iPhone is off by
    /// tenths of a degree: more means the iPhone moved or was not on the same side.
    static let maxError = 3.0
    /// The steepest surface, in degrees, a two-step calibration accepts.
    static let maxSlope = 10.0

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
    /// - Returns: `nil` when the result is not plausible: an error over `maxError` or a surface
    ///   steeper than `maxSlope`, which means the iPhone moved or was not turned in place.
    func calibrating(_ target: CalibrationTarget, first: Gravity, second: Gravity) -> Calibration? {
        var result = self
        switch target {
        case .flat:
            let errorX = (first.x + second.x) / 2
            let errorY = (first.y + second.y) / 2
            let slope = Self.tilt(x: (first.x - second.x) / 2, y: (first.y - second.y) / 2)
            guard Self.tilt(x: errorX, y: errorY) <= Self.maxError, slope <= Self.maxSlope else { return nil }
            result.flatX = errorX
            result.flatY = errorY
        case .edge(let edge):
            let firstDeviation = edge.deviation(of: first.rotation)
            let secondDeviation = edge.deviation(of: second.rotation)
            let error = (firstDeviation + secondDeviation) / 2
            let slope = abs(firstDeviation - secondDeviation) / 2
            guard abs(error) <= Self.maxError, slope <= Self.maxSlope else { return nil }
            result.setOffset(error, for: edge)
        }
        return result
    }

    /// This calibration without any offset beyond `maxError`, which no real sensor needs.
    func discardingImplausibleOffsets() -> Calibration {
        var result = self
        for edge in Edge.allCases where abs(offset(for: edge)) > Self.maxError {
            result.setOffset(0, for: edge)
        }
        if Self.tilt(x: flatX, y: flatY) > Self.maxError {
            result.flatX = 0
            result.flatY = 0
        }
        return result
    }

    /// Degrees of tilt for the horizontal part of gravity.
    private static func tilt(x: Double, y: Double) -> Double {
        Angles.degrees(fromRadians: asin(min(1, (x * x + y * y).squareRoot())))
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
    /// The saved format. Anything without it comes from an earlier build and is discarded: the
    /// first builds saved a one-step offset folded into ±45° and never checked, which can be tens
    /// of degrees off (a real iPhone flat on a table read 9,2°).
    static let schemaVersion = 2

    private enum CodingKeys: String, CodingKey {
        case version, bottom, right, top, left, flatX, flatY
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard try container.decodeIfPresent(Int.self, forKey: .version) == Self.schemaVersion else {
            self = .none
            return
        }
        bottom = try container.decodeIfPresent(Double.self, forKey: .bottom) ?? 0
        right = try container.decodeIfPresent(Double.self, forKey: .right) ?? 0
        top = try container.decodeIfPresent(Double.self, forKey: .top) ?? 0
        left = try container.decodeIfPresent(Double.self, forKey: .left) ?? 0
        flatX = try container.decodeIfPresent(Double.self, forKey: .flatX) ?? 0
        flatY = try container.decodeIfPresent(Double.self, forKey: .flatY) ?? 0
        self = discardingImplausibleOffsets()
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.schemaVersion, forKey: .version)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(right, forKey: .right)
        try container.encode(top, forKey: .top)
        try container.encode(left, forKey: .left)
        try container.encode(flatX, forKey: .flatX)
        try container.encode(flatY, forKey: .flatY)
    }
}
