import Foundation
import Testing
@testable import SbuTidy

struct LabelTests {
    private func label(daysAgo: Double, every days: Int = 7, paused: Bool = false) -> DueLabel {
        let clock = ChoreClock(lastDone: Fixtures.daysAgo(daysAgo), pausedAt: paused ? Fixtures.now : nil)
        return DueLabel(ChoreState(frequency: Frequency(days, .day), clock: clock, now: Fixtures.now, calendar: Fixtures.calendar))
    }

    @Test(arguments: [
        (0.0, DueLabel.inDays(7)), (5, .inDays(2)), (6, .tomorrow), (7, .today), (8, .late(days: 1)), (13, .late(days: 6)), (1_000, .late(days: 993)),
    ])
    func dueWordsFollowTheDays(daysAgo: Double, expected: DueLabel) {
        #expect(label(daysAgo: daysAgo) == expected)
    }

    @Test func pausedSaysPausedEvenWhenLate() {
        #expect(label(daysAgo: 100, paused: true) == .paused)
    }

    @Test(arguments: [
        (DueLabel.today, "Oggi"), (.tomorrow, "Domani"), (.paused, "In pausa"),
    ])
    func fixedWordsAreItalianInTheSource(label: DueLabel, key: String) {
        #expect(label.text.key == key)
    }

    @Test func countedWordsUseOneKeyForEveryNumber() {
        #expect(DueLabel.inDays(3).text.key == "Tra %lld giorni")
        #expect(DueLabel.late(days: 1).text.key == "%lld giorni di ritardo")
    }

    @Test(arguments: [(FrequencyUnit.day, "Ogni %lld giorni"), (.week, "Ogni %lld settimane"), (.month, "Ogni %lld mesi")])
    func frequencyWordsHaveOneKeyPerUnit(unit: FrequencyUnit, key: String) {
        #expect(Frequency(2, unit).text.key == key)
    }

    @Test func roomWordsSayTheWorstState() {
        let late = ChoreState(frequency: Frequency(7, .day), clock: ChoreClock(lastDone: Fixtures.daysAgo(9)), now: Fixtures.now, calendar: Fixtures.calendar)
        let clean = ChoreState(frequency: Frequency(7, .day), clock: ChoreClock(lastDone: Fixtures.now), now: Fixtures.now, calendar: Fixtures.calendar)
        #expect(RoomSummary([late, clean]).statusText.key == "%lld in ritardo")
        #expect(RoomSummary([late, clean]).tone == .danger)
        #expect(RoomSummary([clean]).statusText.key == "Pulita")
        #expect(RoomSummary([clean]).tone == .success)
        #expect(RoomSummary([]).statusText.key == "Nessuna attività")
    }
}
