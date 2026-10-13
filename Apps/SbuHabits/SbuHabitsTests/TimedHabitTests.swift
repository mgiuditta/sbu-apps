import Foundation
import Testing
@testable import SbuHabits

struct TimedHabitTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "TimedHabitTests-\(UUID().uuidString).json"))
    private let timerStore = HabitTimerStore(defaults: UserDefaults(suiteName: "TimedHabitTests-\(UUID().uuidString)")!, key: "timer")
    private let plans = PlanLog()

    /// Monday 12 October 2026 at `hour`:`minute`.
    private func date(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: hour, minute: minute))!
    }

    private func model(_ clock: TestClock) -> HabitsModel {
        HabitsModel(store: store, now: { clock.now }, calendar: calendar, scheduleReminders: plans.record, health: FakeHealth(), timerStore: timerStore)
    }

    private func timedModel(_ clock: TestClock, minutes: Int = 20) -> HabitsModel {
        let model = model(clock)
        model.add(title: "Leggere", symbol: "book", timerMinutes: minutes)
        return model
    }

    // MARK: - The habit

    @Test(arguments: [(0, 1), (20, 20), (500, 180)])
    func theLengthIsKeptInRange(minutes: Int, kept: Int) {
        let model = timedModel(TestClock(date(9)), minutes: minutes)

        #expect(model.habits[0].timerMinutes == kept)
        #expect(model.habits[0].timerDuration == .seconds(kept * 60))
    }

    @Test func aTimedHabitIsDoneOnceADay() {
        let model = model(TestClock(date(9)))

        model.add(title: "Leggere", symbol: "book", timesPerDay: 5, timerMinutes: 20)

        #expect(model.habits[0].timesPerDay == 1)
    }

    @Test func anAvoidedOrLinkedHabitIsNeverTimed() {
        let model = model(TestClock(date(9)))

        model.add(title: "Caffè", symbol: "cup.and.saucer", limit: 2, timerMinutes: 20)
        model.add(title: "Meditare", symbol: "brain", health: HealthLink(measure: .mindfulMinutes, goal: 10), timerMinutes: 20)

        #expect(model.habits.map(\.timerMinutes) == [nil, nil])
    }

    @Test func editingCanTakeTheTimerAway() {
        let model = timedModel(TestClock(date(9)))

        model.edit(model.habits[0], title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay)

        #expect(model.habits[0].timerMinutes == nil)
    }

    @Test func anOlderFileLoadsAsNotTimed() throws {
        let json = #"{"version": 1, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "createdOn": 20000, "log": {}}]}"#

        let file = try JSONDecoder().decode(HabitsFile.self, from: Data(json.utf8))

        #expect(file.habits[0].timerMinutes == nil)
        #expect(file.version == 1)
    }

    // MARK: - The countdown

    @Test func startingPlansTheNotificationAtTheEnd() throws {
        let clock = TestClock(date(9))
        let model = timedModel(clock)

        model.startTimer(for: model.habits[0])

        let first = try #require(plans.last?.first)
        #expect(first.endsTimer)
        #expect(first.date == date(9, 20))
        #expect(first.title == "Leggere")
        #expect(timerStore.load() == model.timer)
    }

    @Test func pausingTakesTheNotificationAwayAndResumingPutsItBack() throws {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.startTimer(for: model.habits[0])
        clock.advance(by: 300)

        model.toggleTimerPause()
        #expect(plans.last?.contains(where: \.endsTimer) == false)
        #expect(timerStore.load()?.isRunning == false)

        clock.advance(by: 3_600)
        model.toggleTimerPause()
        #expect(plans.last?.first { $0.endsTimer }?.date == date(10, 20))
    }

    @Test func cancellingLeavesTheHabitToDo() {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.startTimer(for: model.habits[0])

        model.cancelTimer()

        #expect(model.timer == nil)
        #expect(timerStore.load() == nil)
        #expect(model.habits[0].isDone(on: model.today) == false)
        #expect(plans.last?.contains(where: \.endsTimer) == false)
    }

    @Test func segnaFattaMarksItNow() {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.startTimer(for: model.habits[0])
        clock.advance(by: 60)

        model.markTimerDone()

        #expect(model.timer == nil)
        #expect(model.habits[0].isDone(on: model.today))
        #expect(model.habits[0].markHours[model.today] == [9])
    }

    @Test func theEndOnScreenMarksItAndCountsForTheHaptic() {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.startTimer(for: model.habits[0])

        clock.advance(by: 1_199)
        #expect(model.finishTimerIfEnded() == false)

        clock.advance(by: 1)
        #expect(model.finishTimerIfEnded())
        #expect(model.habits[0].isDone(on: model.today))
        #expect(model.timersEnded == 1)
        #expect(timerStore.load() == nil)
    }

    @Test func comingBackAfterTheEndMarksTheDayItStartedAtTheHourItEnded() throws {
        let clock = TestClock(date(23, 50))
        let model = timedModel(clock)
        let startDay = model.today
        model.startTimer(for: model.habits[0])

        // Closed, then opened the next morning.
        clock.advance(by: 9 * 3_600)
        let reopened = self.model(clock)

        let habit = try #require(reopened.habits.first)
        #expect(reopened.timer == nil)
        #expect(timerStore.load() == nil)
        #expect(habit.isDone(on: startDay))
        #expect(habit.isDone(on: reopened.today) == false)
        #expect(habit.markHours[startDay] == [0]) // ended at 00:10
        #expect(reopened.timersEnded == 0)
    }

    @Test func aRunningTimerSurvivesARelaunch() {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.startTimer(for: model.habits[0])
        clock.advance(by: 60)

        let reopened = self.model(clock)

        #expect(reopened.timer == model.timer)
        #expect(reopened.timer?.remaining(at: clock.now) == .seconds(19 * 60))
    }

    @Test func aNewTimerReplacesTheOldOne() {
        let clock = TestClock(date(9))
        let model = timedModel(clock)
        model.add(title: "Meditare", symbol: "brain", timerMinutes: 10)
        model.startTimer(for: model.habits[0])

        model.startTimer(for: model.habits[1])

        #expect(model.timer?.habitID == model.habits[1].id)
        #expect(plans.last?.filter(\.endsTimer).count == 1)
    }

    @Test func deletingTheHabitThrowsItsTimerAway() {
        let model = timedModel(TestClock(date(9)))
        model.startTimer(for: model.habits[0])

        model.delete(model.habits[0])

        #expect(model.timer == nil)
        #expect(timerStore.load() == nil)
    }

    // MARK: - The plan

    @Test func theTimerTakesOnePlaceOfTheLimit() {
        let day = LogicalDay(date(9), calendar: calendar)
        let habits = (0..<5).map { index in
            var habit = Habit(title: "Abitudine \(index)", symbol: "book", createdOn: day - 1)
            habit.reminders = [ReminderTime(hour: 20, minute: 0)]
            return habit
        }
        let timer = HabitTimer(habitID: habits[0].id, title: "Leggere", day: day, duration: .seconds(600), now: date(9))

        let plan = ReminderPlan.reminders(for: habits, timer: timer, now: date(9), startHour: 0, calendar: calendar)

        #expect(plan.count == ReminderPlan.limit)
        #expect(plan.first?.id == ReminderPlan.timerID)
        #expect(plan.dropFirst().allSatisfy { $0.endsTimer == false })
    }

    @Test func aTimerPausedOrPastIsNotPlanned() {
        let day = LogicalDay(date(9), calendar: calendar)
        var paused = HabitTimer(habitID: UUID(), title: "Leggere", day: day, duration: .seconds(600), now: date(9))
        paused.pause(at: date(9, 1))
        let past = HabitTimer(habitID: UUID(), title: "Leggere", day: day, duration: .seconds(600), now: date(8))

        #expect(ReminderPlan.reminders(for: [], timer: paused, now: date(9, 2), startHour: 0, calendar: calendar).isEmpty)
        #expect(ReminderPlan.reminders(for: [], timer: past, now: date(9), startHour: 0, calendar: calendar).isEmpty)
    }
}
