/// A place on the Mix Pad: the listener at 0,0, the pad's edge at distance 1, left is negative x,
/// front is negative y (up on screen).
nonisolated struct MixPoint: Codable, Equatable, Hashable, Sendable {
    var x: Double
    var y: Double

    static let center = MixPoint(x: 0, y: 0)

    var distance: Double { (x * x + y * y).squareRoot() }

    /// The same direction, pulled inside the pad if it was outside.
    var insidePad: MixPoint {
        let length = distance
        return length > 1 ? MixPoint(x: x / length, y: y / length) : self
    }
}
