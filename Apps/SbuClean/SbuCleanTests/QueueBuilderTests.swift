import Foundation
import Testing
@testable import SbuClean

struct QueueBuilderTests {
    private let now = Fixture.date(10, 13)

    /// Newest first, as the library comes.
    private var items: [MediaItem] {
        [
            Fixture.photo("oct-10", on: Fixture.date(10, 10)),
            Fixture.photo("oct-1", on: Fixture.date(10, 1)),
            Fixture.photo("sep-20", on: Fixture.date(9, 20)),
            Fixture.photo("sep-5", on: Fixture.date(9, 5), bytes: 9_000_000, screenshot: true),
            Fixture.photo("aug-2", on: Fixture.date(8, 2), bytes: 3_000_000, screenshot: true),
            Fixture.photo("this-day-2025", on: Fixture.date(10, 13, year: 2025)),
            Fixture.photo("this-day-2023", on: Fixture.date(10, 13, year: 2023)),
        ]
    }

    private func builder(_ state: CleanState = CleanState()) -> QueueBuilder {
        QueueBuilder(items: items, state: state, now: now)
    }

    @Test func recentIsTheLastThirtyDaysNewestFirst() {
        #expect(builder().queue(for: .recent) == ["oct-10", "oct-1", "sep-20"])
    }

    @Test func aMonthGoesOldestFirstAndSkipsWhatIsDecided() {
        var state = CleanState()
        state.set(.keep, for: "sep-20")
        #expect(builder().queue(for: .month(YearMonth(year: 2026, month: 9))) == ["sep-5", "sep-20"])
        #expect(builder(state).queue(for: .month(YearMonth(year: 2026, month: 9))) == ["sep-5"])
    }

    @Test func onThisDayTakesPastYearsOnly() {
        #expect(builder().queue(for: .onThisDay) == ["this-day-2025", "this-day-2023"])
    }

    @Test func laterHoldsOnlyTheItemsSetAside() {
        var state = CleanState()
        state.set(.later, for: "oct-1")
        #expect(builder(state).queue(for: .later) == ["oct-1"])
        #expect(!builder(state).queue(for: .recent).contains("oct-1"))
    }

    @Test(arguments: [SwipeDecision.trash, .keepForever, .keep])
    func decidedItemsLeaveEveryQueue(decision: SwipeDecision) {
        var state = CleanState()
        state.set(decision, for: "oct-10")
        let builder = builder(state)
        #expect(!builder.queue(for: .recent).contains("oct-10"))
        #expect(!builder.queue(for: .random, seed: 1).contains("oct-10"))
    }

    @Test func randomIsRepeatableWithASeedAndCoversEverythingOpen() {
        let first = builder().queue(for: .random, seed: 7)
        #expect(first == builder().queue(for: .random, seed: 7))
        #expect(Set(first) == Set(items.map(\.id)))
    }

    @Test func aCategoryGoesBiggestFirst() {
        #expect(builder().queue(for: .category(.screenshots)) == ["sep-5", "aug-2"])
    }

    @Test func albumKeepsItsOrderAndSkipsDecidedItems() {
        var state = CleanState()
        state.set(.trash, for: "oct-1")
        #expect(builder(state).queue(for: .album(Album(id: "a", title: "A", count: 3)), albumItemIDs: ["sep-20", "oct-1", "oct-10"]) == ["sep-20", "oct-10"])
    }

    @Test func monthsAreNewestFirstWithTheirProgress() {
        var state = CleanState()
        state.set(.keep, for: "oct-10")
        state.set(.trash, for: "oct-1")
        state.set(.later, for: "sep-20")

        let months = builder(state).months()

        #expect(months.map(\.month) == [
            YearMonth(year: 2026, month: 10), YearMonth(year: 2026, month: 9), YearMonth(year: 2026, month: 8),
            YearMonth(year: 2025, month: 10), YearMonth(year: 2023, month: 10),
        ])
        #expect(months[0].isFinished)
        #expect(months[1].decided == 1 && months[1].total == 2)
        #expect(!months[2].isFinished)
    }
}
