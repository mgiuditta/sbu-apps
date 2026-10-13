import Foundation
import Testing
@testable import SbuHabits

/// The numbers of the Statistiche pages.
struct HabitStatisticsTests {
    /// Sunday 1 October 1972; weeks start on Monday here.
    private let today = LogicalDay(ordinal: 1_004)
    private let monday = 2

    private func habit(_ schedule: Schedule = .everyDay, timesPerDay: Int = 1, limit: Int? = nil, age: Int = 30, log: [Int: Int] = [:], skipped: [Int] = []) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", timesPerDay: timesPerDay, schedule: schedule, limit: limit, createdOn: today - age)
        for (daysAgo, count) in log {
            habit.log[today - daysAgo] = count
        }
        habit.skipped = Set(skipped.map { today - $0 })
        return habit
    }

    private func done(_ daysAgo: [Int]) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: daysAgo.map { ($0, 1) })
    }

    private func statistics(_ habit: Habit, _ period: StatisticsPeriod = .all) -> HabitStatistics {
        .habit(habit, period: period, today: today, firstWeekday: monday)
    }

    // MARK: - Period

    @Test(arguments: [
        (StatisticsPeriod.week, 100, 6),
        (.month, 100, 29),
        (.year, 100, 100), // clamped to the oldest habit
        (.year, 400, 364),
        (.all, 400, 400),
        (.week, 3, 3),
        (.all, -2, 0), // a habit "from the future", after the clock moved back
    ])
    func thePeriodStartsAtTheOldestHabitAtTheEarliest(period: StatisticsPeriod, startDaysAgo: Int, firstDaysAgo: Int) {
        #expect(period.firstDay(today: today, start: today - startDaysAgo) == today - firstDaysAgo)
    }

    @Test func everyHabitCountsFromTheOldestOne() {
        let old = habit(age: 50)
        let new = habit(age: 5)

        let all = HabitStatistics.all([new, old], period: .all, today: today, firstWeekday: monday)

        #expect(all.firstDay == today - 50)
        #expect(all.dayCount == 51)
        #expect(statistics(new).dayCount == 6)
    }

    // MARK: - Completion rate

    @Test(arguments: [
        // done days ago, skipped days ago, done, missed
        ([1, 2, 3], [Int](), 3, 2), // created 5 days ago: days 5 and 4 missed, today not over
        ([0, 1, 2, 3], [], 4, 2), // today done counts
        ([1, 2], [3, 4], 2, 1), // skipped days stay out
        ([], [], 0, 5),
    ])
    func aDailyHabitCountsDoneOverDoneAndMissed(done: [Int], skipped: [Int], expectedDone: Int, missed: Int) {
        let tally = statistics(habit(age: 5, log: self.done(done), skipped: skipped)).tally

        #expect(tally == CompletionTally(done: expectedDone, missed: missed))
    }

    @Test(arguments: [
        (CompletionTally(done: 3, missed: 1), 0.75 as Double?),
        (CompletionTally(done: 0, missed: 2), 0),
        (CompletionTally(done: 2, missed: 0), 1),
        (.zero, nil), // nothing expected: no rate, never 0 %
    ])
    func theRateIsDoneOverDoneAndMissed(tally: CompletionTally, rate: Double?) {
        #expect(tally.rate == rate)
    }

    @Test func daysNotExpectedStayOutOfTheRateButTheirMarksAreCompletions() {
        // Monday to Friday, created on Sunday a week ago; done Monday, Tuesday and Saturday.
        let weekdays = habit(.weekdays([2, 3, 4, 5, 6]), age: 7, log: done([6, 5, 1]))

        let numbers = statistics(weekdays)

        #expect(numbers.tally == CompletionTally(done: 2, missed: 3))
        #expect(numbers.completions == 3)
    }

    @Test func anAvoidedHabitIsDoneWithinItsLimitAndMissedOverIt() {
        // Limite 1: 0, 1, 2 (over), skipped, 0, and today 1, within the Limite and not over yet.
        let coffee = habit(limit: 1, age: 5, log: [4: 1, 3: 2, 0: 1], skipped: [2])

        let numbers = statistics(coffee)

        #expect(numbers.tally == CompletionTally(done: 3, missed: 1))
        // Its marks are times given in: its completions are the days done.
        #expect(numbers.completions == 3)
    }

    @Test func anAvoidedHabitOverItsLimitTodayIsMissedAtOnce() {
        let coffee = habit(limit: 1, age: 0, log: [0: 2])

        #expect(statistics(coffee).tally == CompletionTally(done: 0, missed: 1))
    }

    @Test(arguments: [
        // Created on a Monday 20 days ago: 3 of 3, 1 of 3, then this week 2 so far.
        (StatisticsPeriod.all, CompletionTally(done: 6, missed: 2)),
        // Only this week, not over yet: what is done counts, nothing is missed.
        (.week, CompletionTally(done: 2, missed: 0)),
    ])
    func aWeeklyHabitCountsItsGoalOncePerWeek(period: StatisticsPeriod, tally: CompletionTally) {
        let gym = habit(.timesPerWeek(3), age: 20, log: done([20, 19, 18, 17, 10, 1, 0]))

        #expect(statistics(gym, period).tally == tally)
    }

    @Test func aWeekWithEveryDaySkippedAskedForNothing() {
        let gym = habit(.timesPerWeek(2), age: 13, skipped: Array(7...13))

        #expect(statistics(gym).tally == .zero)
    }

    @Test func aMonthlyHabitCountsItsGoalOncePerMonth() {
        // Twice a month, from 22 August: 1 of 2 in August, 3 of 2 in September, 1 today in October.
        let haircut = habit(.timesPerMonth(2), age: 40, log: done([34, 20, 15, 10, 0]))

        #expect(statistics(haircut).tally == CompletionTally(done: 4, missed: 1))
    }

    @Test(arguments: [
        ([Int: Int](), CompletionTally(done: 0, missed: 1)),
        ([3: 1], CompletionTally(done: 1, missed: 0)),
    ])
    func aOneDayHabitCountsOnItsDayOnly(log: [Int: Int], tally: CompletionTally) {
        let dentist = habit(.oneDay(today - 3), age: 10, log: log)

        #expect(statistics(dentist).tally == tally)
    }

    @Test func aTimedHabitCountsLikeAnyHabitDoneOnceADay() {
        var meditate = habit(age: 3, log: done([3, 1]))
        let updated = meditate.update(title: "Meditare", symbol: "brain", timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        #expect(updated)
        #expect(meditate.timerMinutes == 10)

        let numbers = statistics(meditate)

        #expect(numbers.tally == CompletionTally(done: 2, missed: 1))
        #expect(numbers.completions == 2)
    }

    // MARK: - Completions

    @Test func everyTimeMarkedIsACompletionEvenOnADayNotFinished() {
        // Eight glasses: 8, then 3 of 8.
        let water = habit(timesPerDay: 8, age: 2, log: [2: 8, 1: 3])

        let numbers = statistics(water)

        #expect(numbers.completions == 11)
        #expect(numbers.tally == CompletionTally(done: 1, missed: 1))
    }

    @Test func thePeriodLimitsTheCompletions() {
        let reading = habit(age: 30, log: done([20, 10, 5, 1]))

        #expect(statistics(reading, .week).completions == 2)
        #expect(statistics(reading, .month).completions == 4)
    }

    // MARK: - Serie migliore

    @Test(arguments: [
        (StatisticsPeriod.all, 5),
        (.month, 5),
        (.week, 3), // the run of five ended two weeks ago
    ])
    func theBestSerieIsTheLongestInsideThePeriod(period: StatisticsPeriod, best: Int) {
        let reading = habit(age: 30, log: done([20, 19, 18, 17, 16, 3, 2, 1]))

        #expect(statistics(reading, period).bestStreak == best)
    }

    @Test func aRunCrossingTheStartOfThePeriodCountsFromItsStart() {
        let reading = habit(age: 30, log: done([8, 7, 6, 5]))

        #expect(statistics(reading, .week).bestStreak == 2)
        #expect(statistics(reading).bestStreak == 4)
    }

    @Test func theBestWeeklySerieInsideThePeriodCountsWeeks() {
        // Three weeks reached in a row, two to four weeks ago.
        let gym = habit(.timesPerWeek(2), age: 60, log: done([7, 14, 15, 21, 22, 28, 29]))

        #expect(statistics(gym).bestStreak == 3)
        #expect(statistics(gym, .week).bestStreak == 0)
    }

    @Test(arguments: [
        (StatisticsPeriod.all, 3),
        (.week, 2),
    ])
    func everyHabitsBestSerieIsTheBestSeriePiena(period: StatisticsPeriod, best: Int) {
        // Both done 9 to 7 days ago and 2 and 1 days ago; walking missed 3 to 6 days ago.
        let reading = habit(age: 9, log: done(Array(1...9)))
        let walking = habit(age: 9, log: done([9, 8, 7, 2, 1]))

        let all = HabitStatistics.all([reading, walking], period: period, today: today, firstWeekday: monday)

        #expect(all.bestStreak == best)
    }

    // MARK: - Line

    @Test(arguments: [
        (7, 7),
        (30, 30),
        (31, 16), // two days a point
        (365, 29),
        (1_000, 30),
    ])
    func theLineHasAboutThirtyPointsWhateverThePeriod(days: Int, points: Int) {
        let line = HabitStatistics.line(of: Array(repeating: CompletionTally(done: 1, missed: 0), count: days), from: today - (days - 1))

        #expect(line.count == points)
        #expect(line.last?.lastDay == today)
        #expect(line.first?.firstDay == today - (days - 1))
    }

    @Test func aStretchWithNothingExpectedHasNoPointAndKeepsItsPlace() {
        let days = [CompletionTally(done: 1, missed: 1), .zero, CompletionTally(done: 1, missed: 0)]

        let line = HabitStatistics.line(of: days, from: today - 2)

        #expect(line.map(\.index) == [0, 2])
        #expect(line.map(\.rate) == [0.5, 1])
    }

    // MARK: - Weekdays and hours

    @Test func theWeekdayBarsStartOnTheFirstDayOfTheUsersWeek() {
        // Done every day for two weeks, twice on Sundays (today and a week ago).
        let water = habit(timesPerDay: 2, age: 13, log: Dictionary(uniqueKeysWithValues: (0...13).map { ($0, $0 % 7 == 0 ? 2 : 1) }))

        let weekdays = statistics(water).weekdays

        #expect(weekdays.map(\.weekday) == [2, 3, 4, 5, 6, 7, 1])
        #expect(weekdays.map(\.count) == [2, 2, 2, 2, 2, 2, 4])
    }

    @Test func theHourCurveLeavesOutHabitsToAvoidAndDaysWithoutHours() {
        var reading = habit(age: 5, log: [5: 1]) // marked before hours were saved
        reading.mark(on: today - 1, hour: 8)
        reading.mark(on: today, hour: 21)
        var coffee = habit(limit: 2, age: 5)
        coffee.mark(on: today, hour: 9)

        let all = HabitStatistics.all([reading, coffee], period: .all, today: today, firstWeekday: monday)

        #expect(all.hours[8] == 1)
        #expect(all.hours[21] == 1)
        #expect(all.hours[9] == 0)
        #expect(all.hours.reduce(0, +) == 2)
        #expect(all.hasHours)
        #expect(statistics(habit(age: 5, log: [5: 1])).hasHours == false)
    }
}
