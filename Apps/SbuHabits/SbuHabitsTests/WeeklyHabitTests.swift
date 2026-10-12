import Foundation
import Testing
@testable import SbuHabits

/// Weeks run Monday to Sunday here (`firstWeekday` 2), and today is a Sunday: the last day of
/// the current week, which started six days ago.
struct WeeklyHabitTests {
    private let today = LogicalDay(ordinal: 1_004)
    private let monday = 2

    private func gym(timesPerWeek: Int = 3, age: Int = 60, doneDaysAgo: [Int]) -> Habit {
        var habit = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(timesPerWeek), createdOn: today - age)
        for daysAgo in doneDaysAgo {
            habit.log[today - daysAgo] = 1
        }
        return habit
    }

    @Test(arguments: [(2, 6), (1, 0)])
    func theWeekStartsOnTheUsersFirstWeekday(firstWeekday: Int, daysBack: Int) {
        #expect(today.weekStart(firstWeekday: firstWeekday) == today - daysBack)
    }

    @Test func progressCountsTheDaysDoneThisWeek() {
        let progress = HabitProgress(of: gym(doneDaysAgo: [6, 4, 8]), today: today, firstWeekday: monday)

        #expect(progress.done == 2) // eight days ago was last week
        #expect(progress.goal == 3)
        #expect(progress.isComplete == false)
    }

    @Test(arguments: [
        ([7, 9, 11, 14, 16, 18], 2), // last two weeks reached, this week not yet: it does not break
        ([0, 2, 4, 7, 9, 11, 14, 16, 18], 3), // this week reached too
        ([7, 9, 11, 14, 16], 1), // the week before last fell short
        ([0, 1], 0),
    ])
    func theSerieCountsWeeksInARowWithTheGoalReached(doneDaysAgo: [Int], weeks: Int) {
        #expect(Streak.current(of: gym(doneDaysAgo: doneDaysAgo), today: today, firstWeekday: monday) == weeks)
    }

    @Test func weeksBeforeCreationNeverCount() {
        let habit = gym(age: 10, doneDaysAgo: [7, 9, 11, 14, 16, 18])

        #expect(Streak.current(of: habit, today: today, firstWeekday: monday) == 1)
    }

    @Test func weeklyHabitsStayOutOfTheFullStreak() {
        var daily = Habit(title: "Leggere", symbol: "book", createdOn: today - 60)
        for daysAgo in 0...3 {
            daily.log[today - daysAgo] = 1
        }

        #expect(Streak.full(of: [daily, gym(doneDaysAgo: [])], today: today) == 4)
        #expect(Streak.full(of: [gym(doneDaysAgo: [0])], today: today) == 0)
    }

    @Test(arguments: [
        ([Int](), true), // goal not reached
        ([1, 2, 3], false), // reached, not marked today
        ([0, 1, 2], true), // reached today: stays to show it
    ])
    func theGridShowsAWeeklyHabitUntilItsGoal(doneDaysAgo: [Int], isShown: Bool) {
        let shown = TodayGrid.habits([gym(doneDaysAgo: doneDaysAgo)], on: today, firstWeekday: monday)

        #expect(shown.isEmpty != isShown)
    }

    @Test func aWeeklyHabitIsDoneOnceADay() {
        let model = HabitsModel(store: HabitsStore(url: .temporaryDirectory.appending(path: "WeeklyHabitTests-\(UUID().uuidString).json")))

        model.add(title: "Palestra", symbol: "dumbbell", timesPerDay: 4, schedule: .timesPerWeek(9))

        #expect(model.habits[0].timesPerDay == 1)
        #expect(model.habits[0].schedule == .timesPerWeek(6))
    }
}
