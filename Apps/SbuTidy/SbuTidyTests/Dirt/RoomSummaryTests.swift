import Foundation
import Testing
@testable import SbuTidy

struct RoomSummaryTests {
    /// A weekly chore done `daysAgo` days ago, paused if asked.
    private func state(_ daysAgo: Double, paused: Bool = false) -> ChoreState {
        ChoreState(
            frequency: Frequency(7, .day),
            clock: ChoreClock(lastDone: Fixtures.daysAgo(daysAgo), pausedAt: paused ? Fixtures.daysAgo(0) : nil),
            now: Fixtures.now, calendar: Fixtures.calendar
        )
    }

    @Test func emptyRoom() {
        let summary = RoomSummary([])
        #expect(summary.status == .empty)
        #expect(summary.level == 0)
        #expect(summary.choreCount == 0)
    }

    @Test(arguments: [
        ([1.0, 2], RoomSummary.Status.clean, 0, 0),
        ([1.0, 7], .due, 1, 0),
        ([7.0, 9], .overdue, 2, 1),
        ([9.0, 10, 30], .overdue, 3, 3),
    ])
    func statusIsTheWorstChore(ages: [Double], status: RoomSummary.Status, toDo: Int, overdue: Int) {
        let summary = RoomSummary(ages.map { state($0) })
        #expect(summary.status == status)
        #expect(summary.toDoCount == toDo)
        #expect(summary.overdueCount == overdue)
    }

    @Test func allPausedRoomSaysSo() {
        let summary = RoomSummary([state(30, paused: true), state(1, paused: true)])
        #expect(summary.status == .paused)
        #expect(summary.level == 0)
    }

    @Test func levelAveragesTheActiveChoresOnly() {
        let summary = RoomSummary([state(0), state(3.5), state(70), state(70, paused: true)])
        #expect(abs(summary.level - 0.5) < 0.000_1)
        #expect(summary.choreCount == 4)
    }
}
