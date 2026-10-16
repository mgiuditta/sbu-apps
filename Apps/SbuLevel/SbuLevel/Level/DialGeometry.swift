/// The clinometer's reading of an edge, as on a dial. Positions are degrees clockwise from the top of the screen.
///
/// The dial turns with the iPhone and reads like a protractor in four quarters: 0° at the top and
/// bottom, 90° at the sides. Turned a quarter
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

    /// The dial's turn after a drag of `degrees`: a turn of one or three quarters swaps 0° and 90°.
    static func turn(_ dialTurn: Double, draggedBy degrees: Double) -> Double {
        let quarters = Int((degrees / quarterTurn).rounded())
        return quarters.isMultiple(of: 2) ? dialTurn : quarterTurn - dialTurn
    }
}
