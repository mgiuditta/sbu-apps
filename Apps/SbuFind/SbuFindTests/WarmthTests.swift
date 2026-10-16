import Foundation
import Testing
@testable import SbuFind

struct WarmthTests {
    @Test(arguments: [
        (-100, Warmth.cold),
        (-80, .cold),
        (-79, .warm),
        (-65, .warm),
        (-64, .hot),
        (-53, .hot),
        (-52, .veryClose),
        (-30, .veryClose),
    ])
    func signalGivesTheWord(rssi: Int, warmth: Warmth) {
        #expect(Warmth(proximity: Proximity(rssi: rssi)) == warmth)
    }

    @Test(arguments: Warmth.allCases)
    func eachWordStartsAtItsLowerBound(warmth: Warmth) {
        let bound = Warmth.lowerBound(of: warmth)
        #expect(Warmth(proximity: .init(value: bound)) == warmth)
        if bound > 0 {
            #expect(Warmth(proximity: .init(value: bound - 1)) < warmth)
        }
    }

    @Test func boundsGoUpWithTheWords() {
        let bounds = Warmth.allCases.map(Warmth.lowerBound(of:))
        #expect(bounds == bounds.sorted())
        #expect(Set(bounds).count == bounds.count)
        #expect(bounds.first == 0)
    }

    @Test func everyWordHasItsOwnSymbolAndName() {
        #expect(Set(Warmth.allCases.map(\.systemImage)).count == Warmth.allCases.count)
        #expect(Set(Warmth.allCases.map { String(localized: $0.name) }).count == Warmth.allCases.count)
    }

    @Test func orderFollowsTheGame() {
        #expect(Warmth.allCases.sorted() == [.cold, .warm, .hot, .veryClose])
    }
}
