/// How much of a signal ring is filled for a proximity, as in Find Air's rings.
nonisolated enum RingFill {
    /// The thinnest arc drawn for a device that is heard at all: a ring at 1 % would be a dot
    /// lost under the round cap.
    static let minimumVisible = 0.03

    /// From 0 (not heard) to 1 (touching), never below `minimumVisible` once there is a signal.
    static func fraction(for proximity: Proximity) -> Double {
        guard proximity.value > 0 else { return 0 }
        return max(minimumVisible, Double(proximity.value) / 100)
    }
}
