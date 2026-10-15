/// What the figure says for a reading, in the chosen unit.
nonisolated struct Readout: Equatable, Sendable {
    var reading: LevelReading
    var unit: AngleUnit

    /// The degrees the figure converts.
    var angle: Double { reading.angle }

    /// The degrees the figure shows when the iPhone is level.
    var levelAngle: Double { reading.levelAngle }

    /// Level when the figure shows what it shows level, in the chosen unit, so "In bolla" and the
    /// figure always agree: whole degrees are level from -0,5° to 0,5°.
    var isLevel: Bool {
        unit.value(forDegrees: angle) == unit.value(forDegrees: levelAngle)
    }
}
