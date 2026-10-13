import Testing
@testable import SbuClean

struct FeatureDistanceTests {
    @Test func distanceIsEuclidean() {
        #expect(FeatureDistance.between([0, 0, 0], [3, 4, 0]) == 5)
        #expect(FeatureDistance.between([1, 2], [1, 2]) == 0)
    }

    @Test func mismatchedPrintsAreInfinitelyFar() {
        #expect(FeatureDistance.between([1, 2], [1, 2, 3]) == .infinity)
        #expect(FeatureDistance.between([], []) == .infinity)
    }

    /// The block product must find exactly the pairs a plain double loop finds, whatever the
    /// block size, including blocks that do not divide the count.
    @Test(arguments: [2, 7, 64, 256])
    func pairsMatchABruteForceSearch(blockSize: Int) {
        var generator = SeededGenerator(seed: 42)
        let prints = (0..<40).map { _ in (0..<16).map { _ in Float.random(in: -1...1, using: &generator) } }
        let threshold: Float = 2.2

        var expected: [String] = []
        for first in prints.indices {
            for second in (first + 1)..<prints.count where FeatureDistance.between(prints[first], prints[second]) <= threshold {
                expected.append("\(first)-\(second)")
            }
        }
        let found = FeatureDistance.pairs(among: prints, within: threshold, blockSize: blockSize).map { "\($0.0)-\($0.1)" }

        #expect(!expected.isEmpty)
        #expect(Set(found) == Set(expected))
        #expect(found.count == expected.count)
    }

    @Test func fewerThanTwoPrintsHaveNoPairs() {
        #expect(FeatureDistance.pairs(among: [[1, 0]], within: 10).isEmpty)
    }
}
