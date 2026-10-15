/// Decides when going over the limit alerts: once per crossing, and again only after slowing down
/// clearly below the limit, so GPS jitter around it stays silent.
nonisolated struct SpeedLimitAlarm: Equatable, Sendable {
    private var isArmed = true

    /// Returns whether this reading should alert, and remembers it.
    /// - Parameters:
    ///   - speed: Metres per second, or `nil` without a fix; a missing fix changes nothing.
    ///   - limit: The current limit, or `nil` when it is off.
    mutating func shouldAlert(speed: Double?, limit: SpeedLimit?) -> Bool {
        guard let limit else {
            isArmed = true
            return false
        }
        guard let speed else { return false }

        if limit.isExceeded(byMetersPerSecond: speed) {
            defer { isArmed = false }
            return isArmed
        }
        if limit.unit.value(ofMetersPerSecond: speed) <= Double(limit.value) - limit.rearmMargin {
            isArmed = true
        }
        return false
    }
}
