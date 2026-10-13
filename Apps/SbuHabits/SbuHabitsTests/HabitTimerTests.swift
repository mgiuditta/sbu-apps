import Foundation
import Testing
@testable import SbuHabits

struct HabitTimerTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private let day = LogicalDay(ordinal: 20_000)

    private func timer(minutes: Int = 3) -> HabitTimer {
        HabitTimer(habitID: UUID(), title: "Leggere", day: day, duration: .seconds(minutes * 60), now: start)
    }

    private func at(_ seconds: Double) -> Date {
        start.addingTimeInterval(seconds)
    }

    @Test func aStartedTimerRunsToAnEndDate() {
        let timer = timer()

        #expect(timer.isRunning)
        #expect(timer.endDate == at(180))
        #expect(timer.remaining(at: start) == .seconds(180))
    }

    @Test(arguments: [(0.0, 180), (0.4, 180), (1, 179), (179.2, 1), (180, 0), (500, 0)])
    func theTimeLeftRoundsUpToTheSecond(elapsed: Double, left: Int) {
        #expect(timer().remaining(at: at(elapsed)) == .seconds(left))
    }

    @Test(arguments: [(0.0, false), (179.9, false), (180, true), (3_600, true)])
    func itEndsAtItsEndDate(elapsed: Double, isFinished: Bool) {
        #expect(timer().isFinished(at: at(elapsed)) == isFinished)
    }

    @Test(arguments: [(0.0, 0.0), (90, 0.5), (180, 1), (400, 1)])
    func theProgressFillsTheRing(elapsed: Double, progress: Double) {
        #expect(timer().progress(at: at(elapsed)) == progress)
    }

    @Test func aPauseKeepsTheTimeLeftAndNeverEnds() {
        var timer = timer()

        timer.pause(at: at(60.5))

        #expect(timer.isRunning == false)
        #expect(timer.endDate == nil)
        #expect(timer.remaining(at: at(10_000)) == .seconds(120))
        #expect(timer.isFinished(at: at(10_000)) == false)
    }

    @Test func resumingRunsForTheTimeThatWasLeft() {
        var timer = timer()
        timer.pause(at: at(60))

        timer.resume(at: at(1_000))

        #expect(timer.isRunning)
        #expect(timer.endDate == at(1_120))
        #expect(timer.remaining(at: at(1_000)) == .seconds(120))
    }

    @Test func pausingTwiceOrResumingARunningTimerChangesNothing() {
        let started = timer()
        var running = started
        running.resume(at: at(30))
        var paused = started
        paused.pause(at: at(30))
        let once = paused

        paused.pause(at: at(90))

        #expect(running == started)
        #expect(paused == once)
    }

    @Test func onlyATimedHabitStartsATimer() {
        var timed = Habit(title: "Leggere", symbol: "book", createdOn: day)
        _ = timed.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, timerMinutes: 20, from: day)
        let plain = Habit(title: "Camminare", symbol: "figure.walk", createdOn: day)

        #expect(HabitTimer(habit: timed, day: day, now: start)?.endDate == at(1_200))
        #expect(HabitTimer(habit: plain, day: day, now: start) == nil)
    }

    @Test func theStoreKeepsTheTimerUntilItIsCleared() throws {
        let defaults = try #require(UserDefaults(suiteName: "HabitTimerTests-\(UUID().uuidString)"))
        let store = HabitTimerStore(defaults: defaults, key: "timer")
        var paused = timer()
        paused.pause(at: at(10))

        store.save(paused)
        #expect(store.load() == paused)

        store.save(nil)
        #expect(store.load() == nil)
    }
}
