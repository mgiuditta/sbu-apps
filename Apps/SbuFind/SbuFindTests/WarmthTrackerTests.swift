import Testing
@testable import SbuFind

struct WarmthTrackerTests {
    private func track(_ values: [Int]) -> [Warmth] {
        var tracker = WarmthTracker()
        return values.map { tracker.update(with: Proximity(value: $0)) }
    }

    @Test(arguments: [(0, Warmth.cold), (35, .warm), (60, .hot), (80, .veryClose), (100, .veryClose)])
    func theFirstReadingGivesThePlainWord(value: Int, warmth: Warmth) {
        #expect(track([value]) == [warmth])
    }

    @Test func goingUpIsImmediate() {
        #expect(track([10, 35, 60, 80]) == [.cold, .warm, .hot, .veryClose])
    }

    @Test func aJumpSkipsWords() {
        #expect(track([0, 90]) == [.cold, .veryClose])
        #expect(track([90, 0]) == [.veryClose, .cold])
    }

    /// The reading hovers just around the Caldo threshold: the word holds.
    @Test func hoveringOnAThresholdDoesNotFlip() {
        #expect(track([60, 59, 61, 57, 60, 55, 58]) == Array(repeating: .hot, count: 7))
    }

    @Test(arguments: [
        (Warmth.warm, 35),
        (.hot, 60),
        (.veryClose, 80),
    ])
    func aWordDropsOnlyBelowItsMargin(warmth: Warmth, threshold: Int) {
        let inside = threshold - WarmthTracker.margin
        let below = inside - 1
        let words = track([threshold, inside, below])
        #expect(words[0] == warmth)
        #expect(words[1] == warmth)
        #expect(words[2] < warmth)
    }

    @Test func droppingFarLandsOnThePlainWord() {
        #expect(track([85, 40]) == [.veryClose, .warm])
        #expect(track([85, 76, 56, 33]) == [.veryClose, .veryClose, .hot, .warm])
    }

    @Test func comingBackUpAfterADropIsImmediate() {
        #expect(track([60, 50, 60]) == [.hot, .warm, .hot])
    }

    @Test func coldNeverDropsFurther() {
        #expect(track([0, 0, 0]) == [.cold, .cold, .cold])
    }

    @Test func resetForgetsTheWord() {
        var tracker = WarmthTracker()
        tracker.update(with: Proximity(value: 62))
        tracker.reset()
        #expect(tracker.warmth == nil)
        #expect(tracker.update(with: Proximity(value: 57)) == .warm)
    }

    /// Whatever the readings, the word is never more than one margin away from the plain one.
    @Test func neverFarFromThePlainWord() {
        var tracker = WarmthTracker()
        var value = 50
        for step in 0..<500 {
            value = min(100, max(0, value + (step * 37 % 11) - 5))
            let proximity = Proximity(value: value)
            let word = tracker.update(with: proximity)
            #expect(word >= Warmth(proximity: proximity))
            #expect(word <= Warmth(proximity: Proximity(value: min(100, value + WarmthTracker.margin))))
        }
    }
}
