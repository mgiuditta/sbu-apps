/// The word on the finder, with hysteresis: it goes up as soon as the proximity crosses the next
/// threshold, and back down only once it falls `margin` points below the current one.
///
/// A reading that hovers on a threshold would otherwise flip Caldo and Tiepido every second.
nonisolated struct WarmthTracker: Equatable, Sendable {
    /// Points below a word's threshold before the word drops.
    static let margin = 5

    private(set) var warmth: Warmth?

    /// Takes in the latest proximity and returns the word to show.
    @discardableResult
    mutating func update(with proximity: Proximity) -> Warmth {
        let plain = Warmth(proximity: proximity)
        guard let current = warmth else {
            warmth = plain
            return plain
        }
        if plain > current {
            warmth = plain
        } else if plain < current {
            // Down only as far as the margin allows: from the word whose threshold minus the
            // margin the proximity still reaches.
            let held = Warmth.allCases.last { candidate in
                candidate <= current && proximity.value >= Warmth.lowerBound(of: candidate) - Self.margin
            } ?? .cold
            warmth = max(plain, held)
        }
        return warmth ?? plain
    }

    mutating func reset() {
        warmth = nil
    }
}
