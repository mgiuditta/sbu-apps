import Foundation
import Testing
@testable import SbuTidy

struct UrgencyTests {
    @Test func dirtiestComesFirstRelativeToFrequency() {
        // One day late on a weekly chore (8/7) beats two days late on a monthly one (~32/30).
        let weekly = Fixtures.chore("Settimanale", every: 7, lastDone: Fixtures.daysAgo(8))
        let monthly = Fixtures.chore("Mensile", every: 30, lastDone: Fixtures.daysAgo(32))
        let fresh = Fixtures.chore("Appena fatta", every: 1, lastDone: Fixtures.now)
        let order = Urgency.sorted([fresh, monthly, weekly], at: Fixtures.now, calendar: Fixtures.calendar).map(\.chore.name)
        #expect(order == ["Settimanale", "Mensile", "Appena fatta"])
    }

    @Test func pausedGoLastEvenWhenFilthy() {
        let paused = Fixtures.chore("Ferma", lastDone: Fixtures.daysAgo(300), pausedAt: Fixtures.daysAgo(1))
        let clean = Fixtures.chore("Pulita", lastDone: Fixtures.now)
        let order = Urgency.sorted([paused, clean], at: Fixtures.now, calendar: Fixtures.calendar).map(\.chore.name)
        #expect(order == ["Pulita", "Ferma"])
    }

    @Test func tiesGoByNameThenNeverJump() {
        let lastDone = Fixtures.daysAgo(3)
        let chores = ["Vetri", "armadio", "Bagno"].map { Fixtures.chore($0, lastDone: lastDone) }
        let first = Urgency.sorted(chores, at: Fixtures.now, calendar: Fixtures.calendar).map(\.chore.name)
        let second = Urgency.sorted(chores.reversed(), at: Fixtures.now, calendar: Fixtures.calendar).map(\.chore.name)
        #expect(first == ["armadio", "Bagno", "Vetri"])
        #expect(first == second)
    }

    @Test func emptyStaysEmpty() {
        #expect(Urgency.sorted([], at: Fixtures.now, calendar: Fixtures.calendar).isEmpty)
    }
}
