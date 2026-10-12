/// Offsets that make the current position read 0°, one per mode.
nonisolated struct Calibration: Codable, Equatable, Sendable {
    /// Clinometer offset in degrees.
    var edge = 0.0
    /// Gravity x and y measured when the bubble level was calibrated.
    var flatX = 0.0
    var flatY = 0.0

    /// No offsets: the sensor as it comes.
    static let none = Calibration()

    /// Returns a calibration where `gravity` reads 0° in its mode; the other mode keeps its offset.
    func levelling(_ gravity: Gravity) -> Calibration {
        var result = self
        switch LevelReading.mode(for: gravity) {
        case .flat:
            result.flatX = gravity.x
            result.flatY = gravity.y
        case .edge:
            result.edge = LevelReading.edgeDeviation(for: gravity)
        }
        return result
    }
}
