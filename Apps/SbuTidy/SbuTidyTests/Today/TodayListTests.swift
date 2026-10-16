import Foundation
import Testing
@testable import SbuTidy

struct TodayListTests {
    private let kitchen = UUID()
    private let bathroom = UUID()

    private func list(_ chores: [ChoreSnapshot], _ filter: TodayFilter) -> TodayList {
        TodayList(chores, filter: filter, now: Fixtures.now, calendar: Fixtures.calendar)
    }

    @Test func toDoGroupsByRoomInYourOrder() {
        let chores = [
            Fixtures.chore("WC", room: "Bagno", roomID: bathroom, roomOrder: 0, lastDone: Fixtures.daysAgo(9)),
            Fixtures.chore("Piatti", room: "Cucina", roomID: kitchen, roomOrder: 1, every: 1, lastDone: Fixtures.daysAgo(3)),
            Fixtures.chore("Forno", room: "Cucina", roomID: kitchen, roomOrder: 1, every: 30, lastDone: Fixtures.daysAgo(31)),
            Fixtures.chore("Specchio", room: "Bagno", roomID: bathroom, roomOrder: 0, lastDone: Fixtures.daysAgo(1)),
        ]
        let list = list(chores, .toDo)
        #expect(list.sections.map(\.roomName) == ["Bagno", "Cucina"])
        #expect(list.sections[0].items.map(\.chore.name) == ["WC"])
        #expect(list.sections[1].items.map(\.chore.name) == ["Piatti", "Forno"])
        #expect(list.toDoCount == 3)
        #expect(list.overdueCount == 3)
    }

    @Test func countIsTheSameWhateverTheFilter() {
        let chores = [
            Fixtures.chore(lastDone: Fixtures.daysAgo(7)),
            Fixtures.chore(lastDone: Fixtures.daysAgo(3)),
        ]
        #expect(list(chores, .toDo).toDoCount == 1)
        #expect(list(chores, .upcoming).toDoCount == 1)
        #expect(list(chores, .toDo).overdueCount == 0)
    }

    @Test(arguments: [(30.0, 1, true), (30, 7, true), (30, 8, false), (30, 30, false)])
    func upcomingLooksAWeekAhead(every days: Double, dueIn: Int, shown: Bool) {
        let chore = Fixtures.chore(every: Int(days), lastDone: Fixtures.daysAgo(days - Double(dueIn)))
        #expect(list([chore], .upcoming).isEmpty == !shown)
    }

    @Test func upcomingLeavesOutWhatIsAlreadyDueAndWhatIsPaused() {
        let chores = [
            Fixtures.chore("Oggi", lastDone: Fixtures.daysAgo(7)),
            Fixtures.chore("Ferma", lastDone: Fixtures.daysAgo(5), pausedAt: Fixtures.daysAgo(1)),
        ]
        #expect(list(chores, .upcoming).isEmpty)
    }

    @Test func upcomingGoesByDueDate() throws {
        let chores = [
            Fixtures.chore("Tra 5", roomID: kitchen, every: 30, lastDone: Fixtures.daysAgo(25)),
            Fixtures.chore("Tra 1", roomID: kitchen, every: 2, lastDone: Fixtures.daysAgo(1)),
            Fixtures.chore("Tra 3", roomID: kitchen, every: 7, lastDone: Fixtures.daysAgo(4)),
        ]
        let section = try #require(list(chores, .upcoming).sections.first)
        #expect(section.items.map(\.chore.name) == ["Tra 1", "Tra 3", "Tra 5"])
    }

    @Test func pausedNeverShowsUpAsToDo() {
        let chore = Fixtures.chore(lastDone: Fixtures.daysAgo(99), pausedAt: Fixtures.daysAgo(1))
        let list = list([chore], .toDo)
        #expect(list.isEmpty)
        #expect(list.toDoCount == 0)
    }

    @Test(arguments: TodayFilter.allCases)
    func noChoresNoSections(filter: TodayFilter) {
        let list = list([], filter)
        #expect(list.isEmpty)
        #expect(list.toDoCount == 0)
    }

    @Test func roomsWithTheSameOrderGoByName() {
        let chores = [
            Fixtures.chore(room: "Studio", roomID: UUID(), lastDone: Fixtures.daysAgo(8)),
            Fixtures.chore(room: "Bagno", roomID: UUID(), lastDone: Fixtures.daysAgo(8)),
        ]
        #expect(list(chores, .toDo).sections.map(\.roomName) == ["Bagno", "Studio"])
    }
}
