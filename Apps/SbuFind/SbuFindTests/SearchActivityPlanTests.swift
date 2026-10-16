import Foundation
import Testing
@testable import SbuFind

struct SearchActivityPlanTests {
    typealias State = SearchActivityAttributes.ContentState

    let attributes = SearchActivityAttributes(deviceName: "Buds Pro", systemImage: "airpods")
    let start = Advertisement.start

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    @Test func beginStarts() {
        var plan = SearchActivityPlan()
        let state = State(percent: 40, warmth: .warm)
        #expect(plan.begin(attributes, state: state, at: start) == .start(attributes, state))
        #expect(plan.isActive)
    }

    @Test func nothingHappensBeforeTheStart() {
        var plan = SearchActivityPlan()
        #expect(plan.follow(State(percent: 40, warmth: .warm), at: start) == .none)
        #expect(plan.found(State(percent: 95, warmth: .veryClose)) == .none)
        #expect(plan.close() == .none)
    }

    @Test func theSameStateIsNotSentAgain() {
        var plan = SearchActivityPlan()
        let state = State(percent: 40, warmth: .warm)
        _ = plan.begin(attributes, state: state, at: start)
        #expect(plan.follow(state, at: at(5)) == .none)
    }

    @Test(arguments: [(0.5, false), (0.99, false), (1.0, true), (3.0, true)])
    func updatesAtMostOnceASecond(after seconds: TimeInterval, sends: Bool) {
        var plan = SearchActivityPlan()
        _ = plan.begin(attributes, state: State(percent: 40, warmth: .warm), at: start)
        let next = State(percent: 45, warmth: .warm)
        #expect((plan.follow(next, at: at(seconds)) == .update(next)) == sends)
    }

    @Test func fallingSilentIsSentAtOnce() {
        var plan = SearchActivityPlan()
        _ = plan.begin(attributes, state: State(percent: 40, warmth: .warm), at: start)
        let silent = State(percent: 40, warmth: .warm, isLost: true)
        #expect(plan.follow(silent, at: at(0.1)) == .update(silent))
        let heard = State(percent: 41, warmth: .warm)
        #expect(plan.follow(heard, at: at(0.2)) == .update(heard))
    }

    @Test func aSkippedChangeIsSentAtTheNextChance() {
        var plan = SearchActivityPlan()
        _ = plan.begin(attributes, state: State(percent: 40, warmth: .warm), at: start)
        #expect(plan.follow(State(percent: 50, warmth: .warm), at: at(0.5)) == .none)
        #expect(plan.follow(State(percent: 50, warmth: .warm), at: at(1.2)) == .update(State(percent: 50, warmth: .warm)))
    }

    /// Even when the one-second gap skipped the latest reading, the final card shows it.
    @Test func foundEndsShowingTheCurrentStateAsFound() {
        var plan = SearchActivityPlan()
        _ = plan.begin(attributes, state: State(percent: 70, warmth: .hot), at: start)
        #expect(plan.follow(State(percent: 91, warmth: .veryClose), at: at(0.5)) == .none)
        #expect(plan.found(State(percent: 91, warmth: .veryClose)) == .end(State(percent: 91, warmth: .veryClose, isFound: true)))
        #expect(!plan.isActive)
        #expect(plan.follow(State(percent: 95, warmth: .veryClose), at: at(5)) == .none)
        #expect(plan.close() == .none)
    }

    @Test func closingEndsAtOnceAndOnlyOnce() {
        var plan = SearchActivityPlan()
        _ = plan.begin(attributes, state: State(percent: 40, warmth: .warm), at: start)
        #expect(plan.close() == .end(nil))
        #expect(plan.close() == .none)
    }

    @Test func stateCarriesTheProximityForTheRing() {
        #expect(State(percent: 64, warmth: .hot).proximity.value == 64)
        #expect(State(percent: 140, warmth: .hot).proximity.value == 100)
        #expect(State(percent: -3, warmth: .cold).proximity.value == 0)
    }

    @Test func stateSurvivesEncoding() throws {
        let state = State(percent: 64, warmth: .hot, isLost: true, isFound: false)
        let decoded = try JSONDecoder().decode(State.self, from: JSONEncoder().encode(state))
        #expect(decoded == state)
    }
}
