import Foundation
import Testing
@testable import SbuTidy

struct ChoreStateTests {
    private func state(every value: Int = 7, _ unit: FrequencyUnit = .day, lastDone: Date, pausedAt: Date? = nil, now: Date = Fixtures.now) -> ChoreState {
        ChoreState(frequency: Frequency(value, unit), clock: ChoreClock(lastDone: lastDone, pausedAt: pausedAt), now: now, calendar: Fixtures.calendar)
    }

    @Test(arguments: [
        // Weekly, done N days ago: days until due and status.
        (0.0, 7, ChoreStatus.clean), (1, 6, .clean), (6, 1, .clean), (7, 0, .due), (8, -1, .overdue), (13, -6, .overdue), (400, -393, .overdue),
    ])
    func weeklyChoreStatusFollowsTheDays(daysAgo: Double, daysUntilDue: Int, status: ChoreStatus) {
        let state = state(lastDone: Fixtures.daysAgo(daysAgo))
        #expect(state.daysUntilDue == daysUntilDue)
        #expect(state.status == status)
    }

    @Test func dueLaterTodayIsAlreadyToDo() {
        // Done yesterday at 20:00, daily: due today at 20:00, so on the list from the morning.
        let state = state(every: 1, lastDone: Fixtures.date(2026, 10, 13, 20), now: Fixtures.date(2026, 10, 14, 7))
        #expect(state.status == .due)
        #expect(state.dirtiness < 1)
    }

    @Test func doneThisMorningDailyIsDueTomorrow() {
        let state = state(every: 1, lastDone: Fixtures.date(2026, 10, 14, 8), now: Fixtures.date(2026, 10, 14, 23, 59))
        #expect(state.daysUntilDue == 1)
        #expect(state.status == .clean)
    }

    @Test func midnightTurnsDueIntoOverdue() {
        let lastDone = Fixtures.date(2026, 10, 13, 9)
        #expect(state(every: 1, lastDone: lastDone, now: Fixtures.date(2026, 10, 14, 23, 59)).status == .due)
        #expect(state(every: 1, lastDone: lastDone, now: Fixtures.date(2026, 10, 15, 0, 1)).status == .overdue)
    }

    @Test func endOfDaylightSavingDoesNotShiftTheDueDay() {
        let state = state(every: 1, lastDone: Fixtures.date(2026, 10, 24, 10), now: Fixtures.date(2026, 10, 25, 9))
        #expect(state.daysUntilDue == 0)
        #expect(state.status == .due)
    }

    @Test(arguments: [(0.0, 0.0), (3.5, 0.5), (7, 1), (14, 2), (70, 10)])
    func dirtinessIsTimeOverFrequency(daysAgo: Double, expected: Double) {
        let state = state(lastDone: Fixtures.daysAgo(daysAgo))
        #expect(abs(state.dirtiness - expected) < 0.000_1)
    }

    @Test(arguments: [(0.0, 0.0), (3.5, 0.5), (7, 1), (70, 1)])
    func levelStopsAtFull(daysAgo: Double, expected: Double) {
        #expect(abs(state(lastDone: Fixtures.daysAgo(daysAgo)).level - expected) < 0.000_1)
    }

    @Test func lastDoneInTheFutureIsClean() {
        let state = state(lastDone: Fixtures.now.addingTimeInterval(10 * 86_400))
        #expect(state.dirtiness == 0)
        #expect(state.status == .clean)
    }

    @Test func pausedIsNeverToDoEvenWhenLate() {
        let state = state(lastDone: Fixtures.daysAgo(100), pausedAt: Fixtures.daysAgo(1))
        #expect(state.status == .paused)
        #expect(!state.status.isToDo)
    }

    @Test func pausedChoreKeepsItsDaysToDue() {
        // Paused two days before it was due: it stays two days away however long the pause.
        let clock = ChoreClock(lastDone: Fixtures.daysAgo(15), pausedAt: Fixtures.daysAgo(10))
        for later in [0.0, 5, 50] {
            let now = Fixtures.now.addingTimeInterval(later * 86_400)
            let state = ChoreState(frequency: Frequency(7, .day), clock: clock, now: now, calendar: Fixtures.calendar)
            #expect(state.daysUntilDue == 2)
        }
    }

    @Test func monthlyUsesCalendarMonths() {
        let state = state(every: 1, .month, lastDone: Fixtures.date(2026, 9, 14))
        #expect(state.daysUntilDue == 0)
        #expect(abs(state.dirtiness - 1) < 0.000_1)
    }

    @Test(arguments: [ChoreStatus.due, .overdue])
    func dueAndOverdueAreToDo(status: ChoreStatus) {
        #expect(status.isToDo)
    }

    @Test(arguments: [ChoreStatus.clean, .paused])
    func cleanAndPausedAreNotToDo(status: ChoreStatus) {
        #expect(!status.isToDo)
    }
}
