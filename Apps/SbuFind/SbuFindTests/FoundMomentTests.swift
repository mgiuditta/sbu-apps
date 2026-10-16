import Testing
@testable import SbuFind

struct FoundMomentTests {
    private func run(_ values: [Int]) -> [Bool] {
        var moment = FoundMoment()
        return values.map { moment.update(with: Proximity(value: $0)) }
    }

    @Test(arguments: [(89, false), (90, true), (100, true)])
    func firesAtTheThreshold(value: Int, fires: Bool) {
        #expect(run([value]) == [fires])
    }

    @Test func firesOnceWhileStayingClose() {
        #expect(run([92, 95, 91, 90, 99]) == [true, false, false, false, false])
    }

    @Test func hoveringBetweenTheBoundsDoesNotFireAgain() {
        #expect(run([90, 80, 76, 90, 75, 90]) == [true, false, false, false, false, false])
    }

    @Test func fallingBelowTheRearmBoundFiresAgain() {
        #expect(run([90, 74, 90]) == [true, false, true])
    }

    @Test func climbingSlowlyFiresOnArrival() {
        #expect(run(Array(stride(from: 50, through: 100, by: 5))) == [false, false, false, false, false, false, false, false, true, false, false])
    }

    @Test func resetArmsAgain() {
        var moment = FoundMoment()
        let first = moment.update(with: Proximity(value: 95))
        #expect(first)
        moment.reset()
        #expect(moment.isArmed)
        let second = moment.update(with: Proximity(value: 95))
        #expect(second)
    }
}
