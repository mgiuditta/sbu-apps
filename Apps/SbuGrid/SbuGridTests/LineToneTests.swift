import Testing
@testable import SbuGrid

struct LineToneTests {
    @Test(arguments: LineTone.allCases)
    func theOppositeOfTheOppositeIsItself(tone: LineTone) {
        #expect(tone.opposite != tone)
        #expect(tone.opposite.opposite == tone)
    }

    @Test func darkComesFirst() {
        #expect(LineTone.allCases == [.dark, .light])
    }

    @Test func storedByAStableName() {
        #expect(LineTone.dark.rawValue == "dark")
        #expect(LineTone.light.rawValue == "light")
    }
}
