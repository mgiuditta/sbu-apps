import Testing
@testable import SbuFind

struct RingFillTests {
    @Test(arguments: [(0, 0.0), (1, 0.03), (3, 0.03), (4, 0.04), (50, 0.5), (75, 0.75), (100, 1.0)])
    func fillFollowsTheProximityWithAVisibleMinimum(value: Int, fraction: Double) {
        #expect(abs(RingFill.fraction(for: Proximity(value: value)) - fraction) < 0.0001)
    }

    @Test func fillNeverShrinksAsTheSignalGrows() {
        var previous = -1.0
        for value in 0...100 {
            let fraction = RingFill.fraction(for: Proximity(value: value))
            #expect(fraction >= previous)
            #expect((0...1).contains(fraction))
            previous = fraction
        }
    }

    @Test(arguments: [(0, 0.0), (80, 0.8), (100, 1.0)])
    func percentIsTheValueOverAHundred(value: Int, percent: Double) {
        #expect(abs(Proximity(value: value).percent - percent) < 0.0001)
    }

    @Test(arguments: [(0.0, "0%"), (0.8, "80%"), (1.0, "100%")])
    func percentReadsAsInFindAir(percent: Double, text: String) {
        let formatted = percent.formatted(.percent.precision(.fractionLength(0)).locale(.init(identifier: "it_IT")))
        #expect(formatted == text)
    }
}
