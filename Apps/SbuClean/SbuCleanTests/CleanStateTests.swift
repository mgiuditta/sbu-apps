import Foundation
import Testing
@testable import SbuClean

struct CleanStateTests {
    @Test(arguments: [SwipeDecision.keep, .trash, .later, .keepForever])
    func anItemHasOneDecisionAtATime(decision: SwipeDecision) {
        var state = CleanState()
        state.set(.trash, for: "a")
        state.set(decision, for: "a")

        #expect(state.decision(for: "a") == decision)
        #expect(state.trash.filter { $0 == "a" }.count == (decision == .trash ? 1 : 0))
    }

    @Test func clearingADecisionMakesTheItemOpenAgain() {
        var state = CleanState()
        state.set(.later, for: "a")
        state.set(nil, for: "a")
        #expect(state.decision(for: "a") == nil)
    }

    @Test func theBinKeepsItsOrderAndSkipsItemsKeptForever() {
        var state = CleanState()
        state.set(.keepForever, for: "safe")
        state.addToTrash(["b", "a", "safe", "b"])
        state.addToTrash(["c", "a"])

        #expect(state.trash == ["b", "a", "c"])
    }

    @Test func forgettingDeletedItemsClearsEveryList() {
        var state = CleanState()
        state.set(.keep, for: "a")
        state.set(.trash, for: "b")
        state.set(.later, for: "c")
        state.set(.keepForever, for: "d")

        state.forget(["a", "b", "c", "d"])

        #expect(state == CleanState())
    }

    @Test func keepOnlyDropsItemsNoLongerInTheLibrary() {
        var state = CleanState()
        state.set(.trash, for: "gone")
        state.set(.trash, for: "here")
        state.keepOnly(["here"])
        #expect(state.trash == ["here"])
    }

    @Test func survivesAJSONRoundTrip() throws {
        var state = CleanState()
        state.set(.keep, for: "a")
        state.set(.trash, for: "b")
        state.freed.record(count: 3, bytes: 4_000, on: Fixture.date(2, 2))

        let decoded = try JSONDecoder().decode(CleanState.self, from: JSONEncoder().encode(state))

        #expect(decoded == state)
    }

    @Test func freedSpaceAddsUpAndKeepsTheLastDeletion() {
        var freed = FreedSpace()
        freed.record(count: 2, bytes: 100, on: Fixture.date(1, 1))
        freed.record(count: 5, bytes: 300, on: Fixture.date(1, 2))

        #expect(freed.totalCount == 7)
        #expect(freed.totalBytes == 400)
        #expect(freed.lastCount == 5)
        #expect(freed.lastBytes == 300)
    }
}
