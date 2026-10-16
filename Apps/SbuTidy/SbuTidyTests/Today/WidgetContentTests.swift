import Foundation
import Testing
@testable import SbuTidy

struct WidgetContentTests {
    @Test func showsTheToDoDirtiestFirstUpToTheLimit() {
        let chores = (1...8).map { Fixtures.chore("A\($0)", lastDone: Fixtures.daysAgo(Double(6 + $0))) }
        let content = WidgetContent(chores, at: Fixtures.now, calendar: Fixtures.calendar, limit: 5)
        #expect(content.toDoCount == 8)
        #expect(content.overdueCount == 7)
        #expect(content.items.map(\.name) == ["A8", "A7", "A6", "A5", "A4"])
        #expect(!content.isEmpty)
    }

    @Test func whenNothingIsToDoItShowsWhatComesNext() {
        let chores = [
            Fixtures.chore("Tra 5", lastDone: Fixtures.daysAgo(2)),
            Fixtures.chore("Tra 1", lastDone: Fixtures.daysAgo(6)),
            Fixtures.chore("Ferma", lastDone: Fixtures.daysAgo(6), pausedAt: Fixtures.now),
        ]
        let content = WidgetContent(chores, at: Fixtures.now, calendar: Fixtures.calendar, limit: 5)
        #expect(content.toDoCount == 0)
        #expect(content.items.map(\.name) == ["Tra 1", "Tra 5"])
        #expect(content.items.first?.label == .tomorrow)
    }

    @Test func noChoresSaysHowToStart() {
        let content = WidgetContent([], at: Fixtures.now, calendar: Fixtures.calendar, limit: 5)
        #expect(content.isEmpty)
        #expect(content.items.isEmpty)
    }

    @Test(arguments: [0, -4])
    func aLimitOfNothingShowsNothing(limit: Int) {
        let content = WidgetContent([Fixtures.chore(lastDone: Fixtures.daysAgo(9))], at: Fixtures.now, calendar: Fixtures.calendar, limit: limit)
        #expect(content.items.isEmpty)
        #expect(content.toDoCount == 1)
    }

    @Test func choresTurnDueAtMidnightWithoutTheApp() {
        // Weekly, done 6 days ago: tomorrow at midnight it is due.
        let chore = Fixtures.chore(lastDone: Fixtures.daysAgo(6))
        let moments = WidgetContent.moments(from: Fixtures.now, calendar: Fixtures.calendar, days: 3)
        #expect(moments == [Fixtures.now, Fixtures.date(2026, 10, 15, 0), Fixtures.date(2026, 10, 16, 0), Fixtures.date(2026, 10, 17, 0)])
        let counts = moments.map { WidgetContent([chore], at: $0, calendar: Fixtures.calendar, limit: 5).toDoCount }
        #expect(counts == [0, 1, 1, 1])
    }

    @Test(arguments: [0, -1])
    func atLeastOneMidnightAhead(days: Int) {
        #expect(WidgetContent.moments(from: Fixtures.now, calendar: Fixtures.calendar, days: days).count == 2)
    }
}
