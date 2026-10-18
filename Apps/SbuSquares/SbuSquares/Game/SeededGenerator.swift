/// Park–Miller MINSTD, rounded to six decimals: the same seed deals the same pieces on every
/// device and every version.
///
/// The system generator cannot be seeded, and a seed must replay the same game in tests.
nonisolated struct SeededGenerator: Codable, Hashable, Sendable {
    private static let modulus = 2_147_483_647

    private(set) var state: Int

    init(seed: UInt64) {
        let state = Int(seed % UInt64(Self.modulus))
        self.state = state == 0 ? 1 : state
    }

    /// A number in 0...1, six decimals.
    mutating func random() -> Double {
        state = state * 16_807 % Self.modulus
        return (Double(state - 1) / Double(Self.modulus - 1) * 1_000_000).rounded() / 1_000_000
    }

    /// An integer in `range`, each equally likely.
    mutating func int(in range: ClosedRange<Int>) -> Int {
        min(range.lowerBound + Int(random() * Double(range.count)), range.upperBound)
    }

    /// One element of a non-empty `array`.
    mutating func element<T>(of array: [T]) -> T {
        array[int(in: 0...array.count - 1)]
    }

    /// `array` in a random order (Fisher–Yates).
    mutating func shuffled<T>(_ array: [T]) -> [T] {
        var array = array
        for index in array.indices.reversed().dropLast() {
            array.swapAt(index, int(in: 0...index))
        }
        return array
    }
}
