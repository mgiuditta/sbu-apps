import Foundation
import Testing
@testable import SbuHabits

/// The tool screen's grid in pages of six, Aggiungi last, at most 24 habits.
struct HomePagesTests {
    private let today = LogicalDay(ordinal: 20_010)

    private func habits(_ count: Int) -> [Habit] {
        (0..<count).map { Habit(title: "Abitudine \($0)", symbol: "book", createdOn: today - 10) }
    }

    private func store() -> HabitsStore {
        HabitsStore(url: .temporaryDirectory.appending(path: "HomePagesTests-\(UUID().uuidString).json"))
    }

    @Test(arguments: [
        (0, [1]),
        (1, [2]),
        (5, [6]),
        (6, [6, 1]),
        (7, [6, 2]),
        (11, [6, 6]),
        (12, [6, 6, 1]),
        (23, [6, 6, 6, 6]),
    ])
    func aggiungiTakesTheNextPlace(count: Int, pageSizes: [Int]) {
        let pages = HomePages(todayHabits: habits(count), habitCount: count)

        #expect(pages.pages.map(\.count) == pageSizes)
        #expect(pages.pages.last?.last == .add)
        #expect(pages.canAdd)
    }

    @Test func atTheLimitAggiungiGoesAndNoFifthPageAppears() {
        let pages = HomePages(todayHabits: habits(HomePages.habitLimit), habitCount: HomePages.habitLimit)

        #expect(HomePages.habitLimit == 24)
        #expect(pages.pages.map(\.count) == [6, 6, 6, 6])
        #expect(pages.allSlots.contains(.add) == false)
        #expect(pages.canAdd == false)
    }

    @Test func habitsKeepTheUsersOrderAcrossPages() {
        let all = habits(8)
        let pages = HomePages(todayHabits: all, habitCount: all.count)

        #expect(pages.allSlots == all.map(HomePages.Slot.habit) + [.add])
        #expect(pages.pages[1].first == .habit(all[6]))
    }

    /// The limit counts every habit: those not expected today come back on their days.
    @Test(arguments: [(20, 23, true), (20, 24, false), (0, 24, false)])
    func theLimitCountsHabitsNotExpectedToday(shownToday: Int, saved: Int, canAdd: Bool) {
        let pages = HomePages(todayHabits: habits(shownToday), habitCount: saved)

        #expect(pages.canAdd == canAdd)
        #expect(pages.allSlots.count == shownToday + (canAdd ? 1 : 0))
    }

    @Test func anUnreadableFileShowsNoAggiungi() {
        let pages = HomePages(todayHabits: [], habitCount: 0, isAddEnabled: false)

        #expect(pages.pages == [[]])
        #expect(pages.canAdd == false)
    }

    @Test(arguments: [(-1, 0), (0, 0), (1, 1), (2, 1), (9, 1)])
    func aPageThatWentClampsToTheLastOne(page: Int, clamped: Int) {
        let pages = HomePages(todayHabits: habits(7), habitCount: 7)

        #expect(pages.clamped(page) == clamped)
    }

    /// The grid shows what TodayGrid shows: a habit on other weekdays stays out and frees its place.
    @Test func aHabitNotExpectedTodayTakesNoPlace() {
        let model = HabitsModel(store: store(), now: { today.noon(in: .current) })
        model.add(title: "Palestra", symbol: "dumbbell", schedule: .weekdays([(today + 1).weekday]))
        model.add(title: "Leggere", symbol: "book")

        #expect(model.homePages.allSlots == [.habit(model.habits[1]), .add])
    }

    @Test func theModelAddsNothingPastTheLimit() {
        let model = HabitsModel(store: store())
        for index in 0..<HomePages.habitLimit {
            model.add(title: "Abitudine \(index)", symbol: "book")
        }
        #expect(model.canAdd == false)

        model.add(title: "Una di troppo", symbol: "book")

        #expect(model.habits.count == HomePages.habitLimit)
        #expect(model.homePages.canAdd == false)
    }
}
