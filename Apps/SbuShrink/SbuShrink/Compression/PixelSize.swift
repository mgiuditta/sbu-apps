/// A picture size in whole pixels.
nonisolated struct PixelSize: Equatable, Hashable, Sendable {
    /// Encoders want even sides; this is the smallest they take.
    static let minimumSide = 16

    var width: Int
    var height: Int

    /// The size scaled to `percent` of each side, rounded to even pixels and never under
    /// `minimumSide` (unless the source itself is smaller).
    func scaled(toPercent percent: Int) -> PixelSize {
        let factor = Double(percent.clamped(to: 1...100)) / 100
        return PixelSize(width: Self.side(width, factor), height: Self.side(height, factor))
    }

    var pixelCount: Int { width * height }

    private static func side(_ side: Int, _ factor: Double) -> Int {
        guard side > 0 else { return 0 }
        // An odd source side rounds down: the copy is never larger than the source.
        let largestEven = max(side - side % 2, 2)
        let even = min(Int((Double(side) * factor / 2).rounded()) * 2, largestEven)
        return max(even, min(minimumSide, largestEven))
    }
}
