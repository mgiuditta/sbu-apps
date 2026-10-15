/// What the figure says for a reading: in the chosen unit, and from a reference when one is set.
nonisolated struct Readout: Equatable, Sendable {
    var reading: LevelReading
    var unit: AngleUnit
    /// The reading taken as zero by "Azzera qui", or `nil` for the absolute angle.
    var reference: LevelReading?

    init(reading: LevelReading, unit: AngleUnit, reference: LevelReading? = nil) {
        self.reading = reading
        self.unit = unit
        self.reference = reference.flatMap { Self.applies($0, to: reading) ? $0 : nil }
    }

    /// A reference holds only in the mode and on the edge it was taken on.
    static func applies(_ reference: LevelReading, to reading: LevelReading) -> Bool {
        reference.mode == reading.mode && reference.edge == reading.edge
    }

    var isRelative: Bool { reference != nil }

    /// The degrees the figure converts. Relative and signed from the reference: on an edge the
    /// turn since then, clockwise positive; flat the change in tilt; in sight the change in elevation.
    var angle: Double {
        guard let reference else { return reading.angle }
        switch reading.mode {
        case .flat, .sight: return reading.angle - reference.angle
        case .edge: return Angles.normalized(reading.rotation - reference.rotation)
        }
    }

    /// The degrees the figure shows when the iPhone is level, or back on the reference.
    var levelAngle: Double { isRelative ? 0 : reading.levelAngle }

    /// Level, or back on the reference, when the figure shows what it shows there, in the chosen
    /// unit, so the context line and the figure always agree: whole degrees are level from -0,5°
    /// to 0,5°.
    var isLevel: Bool {
        unit.value(forDegrees: angle) == unit.value(forDegrees: levelAngle)
    }
}
