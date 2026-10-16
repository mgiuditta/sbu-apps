/// The "found it" moment on the finder: it fires once when the proximity reaches `threshold`,
/// and can fire again only after falling below `rearmBelow`, so a reading that hovers near the
/// top does not buzz again and again.
nonisolated struct FoundMoment: Equatable, Sendable {
    /// Proximity that means the device is in reach of your hand.
    static var threshold: Int { SignalTuning.current.foundAt }
    /// Proximity below which the moment can happen again.
    static var rearmBelow: Int { SignalTuning.current.foundRearmBelow }

    private(set) var isArmed = true

    /// Takes in the latest proximity and returns `true` when the moment happens.
    mutating func update(with proximity: Proximity) -> Bool {
        if isArmed, proximity.value >= Self.threshold {
            isArmed = false
            return true
        }
        if !isArmed, proximity.value < Self.rearmBelow {
            isArmed = true
        }
        return false
    }

    mutating func reset() {
        isArmed = true
    }
}
