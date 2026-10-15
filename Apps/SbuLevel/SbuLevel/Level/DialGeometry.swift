/// Where things sit on the clinometer dial. Positions are degrees clockwise from the top of the screen.
///
/// The dial turns with the iPhone and reads like a protractor in four quarters: 0° at the top and
/// bottom, 90° at the sides. The needle always points up, away from gravity. Turned a quarter
/// (`dialTurn` 90), the dial reads 0° at the sides and 90° at the top and bottom instead.
nonisolated enum DialGeometry {
    /// The dial turns a quarter at a time; two quarters read the same as none.
    static let quarterTurn = 90.0

    /// The value printed on the dial at `position`: 0 at the top and bottom, 90 at the sides, or
    /// the other way round on a turned dial.
    static func value(at position: Double, dialTurn: Double = 0) -> Double {
        let distance = abs(Angles.normalized(position + dialTurn))
        return distance > 90 ? 180 - distance : distance
    }

    /// Where the needle points for a calibrated device rotation (see `Gravity.rotation`).
    static func needlePosition(rotation: Double) -> Double {
        Angles.normalized(-rotation)
    }

    /// The 0° mark the wedge starts from: the one within a quarter of the needle.
    static func wedgeStart(rotation: Double, dialTurn: Double = 0) -> Double {
        let needle = needlePosition(rotation: rotation)
        let first = -dialTurn
        return abs(Angles.normalized(needle - first)) <= 90 ? first : 180 - dialTurn
    }

    /// The signed sweep from the wedge start to the needle, at most 90° either way.
    static func wedgeSweep(rotation: Double, dialTurn: Double = 0) -> Double {
        Angles.normalized(needlePosition(rotation: rotation) - wedgeStart(rotation: rotation, dialTurn: dialTurn))
    }

    /// The dial's turn after a drag of `degrees`: a turn of one or three quarters swaps 0° and 90°.
    static func turn(_ dialTurn: Double, draggedBy degrees: Double) -> Double {
        let quarters = Int((degrees / quarterTurn).rounded())
        return quarters.isMultiple(of: 2) ? dialTurn : quarterTurn - dialTurn
    }
}
