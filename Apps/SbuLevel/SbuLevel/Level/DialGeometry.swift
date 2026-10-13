/// Where things sit on the clinometer dial. Positions are degrees clockwise from the top of the screen.
///
/// The dial turns with the iPhone and reads like a protractor in four quarters: 0° at the top and
/// bottom, 90° at the sides. The needle always points up, away from gravity.
nonisolated enum DialGeometry {
    /// The value printed on the dial at `position`: 0 at the top and bottom, 90 at the sides.
    static func value(at position: Double) -> Double {
        let distance = abs(Angles.normalized(position))
        return distance > 90 ? 180 - distance : distance
    }

    /// Where the needle points for a calibrated device rotation (see `Gravity.rotation`).
    static func needlePosition(rotation: Double) -> Double {
        Angles.normalized(-rotation)
    }

    /// The 0° mark the wedge starts from: the top one, or the bottom one when the iPhone is upside down.
    static func wedgeStart(rotation: Double) -> Double {
        abs(Angles.normalized(rotation)) <= 90 ? 0 : 180
    }

    /// The signed sweep from the wedge start to the needle, at most 90° either way.
    static func wedgeSweep(rotation: Double) -> Double {
        Angles.normalized(needlePosition(rotation: rotation) - wedgeStart(rotation: rotation))
    }
}
