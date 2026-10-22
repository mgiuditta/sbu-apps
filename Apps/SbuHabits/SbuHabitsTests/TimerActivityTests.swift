import Foundation
import Testing
@testable import SbuHabits

struct TimerActivityTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private let day = LogicalDay(ordinal: 20_000)
    private let habitID = UUID()

    private func timer(minutes: Int = 20) -> HabitTimer {
        HabitTimer(habitID: habitID, title: "Leggere", day: day, duration: .seconds(minutes * 60), now: start)
    }

    private func at(_ seconds: Double) -> Date {
        start.addingTimeInterval(seconds)
    }

    private func face(_ timer: HabitTimer, isStale: Bool = false) -> TimerActivityFace {
        TimerActivityFace(attributes: HabitTimerAttributes(timer: timer, symbol: "book"), state: HabitTimerAttributes.ContentState(timer: timer), isStale: isStale)
    }

    // MARK: - The state

    @Test func theAttributesKeepTheHabitAndTheWholeLength() {
        let attributes = HabitTimerAttributes(timer: timer(), symbol: "book")

        #expect(attributes.habitID == habitID)
        #expect(attributes.title == "Leggere")
        #expect(attributes.symbol == "book")
        #expect(attributes.duration == .seconds(1_200))
    }

    @Test func aRunningTimerRunsToItsEndDate() {
        #expect(HabitTimerAttributes.ContentState(timer: timer()).phase == .running(endsAt: at(1_200)))
    }

    @Test func aPausedTimerKeepsTheExactTimeLeft() {
        var timer = timer()
        timer.pause(at: at(100.5))

        #expect(HabitTimerAttributes.ContentState(timer: timer).phase == .paused(secondsLeft: 1_099.5))
    }

    @Test func theStateSurvivesTheWayToTheActivity() throws {
        var paused = timer()
        paused.pause(at: at(60))
        let states = [HabitTimerAttributes.ContentState(timer: timer()), HabitTimerAttributes.ContentState(timer: paused), .done]

        let data = try JSONEncoder().encode(states)

        #expect(try JSONDecoder().decode([HabitTimerAttributes.ContentState].self, from: data) == states)
    }

    // MARK: - The face

    @Test func whileItRunsTheSystemCountsFromTheWholeLengthToTheEnd() throws {
        var timer = timer()
        timer.pause(at: at(300))
        timer.resume(at: at(900))

        let countdown = try #require(face(timer).countdown)

        // 5 minutes gone, 15 left: the range starts 20 minutes before the new end.
        #expect(countdown == at(600)...at(1_800))
        #expect(face(timer).remaining == nil)
        #expect(face(timer).staleDate == at(1_800))
    }

    @Test(arguments: [(0.0, 0.0), (300, 0.25), (1_200, 1), (5_000, 1)])
    func theRingFillsWithTheTimeGoneBy(elapsed: Double, progress: Double) {
        #expect(face(timer()).progress(at: at(elapsed)) == progress)
    }

    @Test(arguments: [(60.0, 1_140, 0.05), (1_199.2, 1, 1_199.2 / 1_200)])
    func pausedItShowsTheTimeLeftRoundedUp(pausedAt: Double, left: Int, progress: Double) {
        var timer = timer()
        timer.pause(at: at(pausedAt))
        let face = face(timer)

        #expect(face.countdown == nil)
        #expect(face.staleDate == nil)
        #expect(face.remaining == .seconds(left))
        #expect(abs(face.progress(at: at(99_999)) - progress) < 0.000_1)
        #expect(face.isRunning == false)
        #expect(face.isDone == false)
    }

    // Seconds left written out: the arithmetic in the literal timed out the type checker.
    @Test(arguments: [(60, 1800, "30:00"), (90, 1800, "30:00"), (90, 3660, "1:01:00"), (20, 545, "9:05")] as [(Int, Int, String)])
    func pausedTheFigureKeepsTheShapeOfTheSystemsCountdown(minutes: Int, left: Int, reads: String) {
        var timer = timer(minutes: minutes)
        timer.pause(at: at(Double(minutes * 60 - left)))
        let face = face(timer)

        #expect(face.remaining?.formatted(face.clock.locale(Locale(identifier: "it_IT"))) == reads)
    }

    @Test(arguments: [(20, "20:00"), (90, "1:30:00")])
    func theWholeLengthReadsAsAClock(minutes: Int, reads: String) {
        let face = face(timer(minutes: minutes))

        #expect(face.duration.formatted(face.length.locale(Locale(identifier: "it_IT"))) == reads)
    }

    @Test func doneItReadsFattaWithTheCheckmark() {
        let face = TimerActivityFace(attributes: HabitTimerAttributes(timer: timer(), symbol: "book"), state: .done)

        #expect(face.isDone)
        #expect(face.symbol == "checkmark")
        #expect(face.countdown == nil)
        #expect(face.remaining == nil)
        #expect(face.progress(at: start) == 1)
    }

    @Test(arguments: [false, true])
    func pastTheEndARunningTimerReadsDone(isStale: Bool) {
        let face = face(timer(), isStale: isStale)

        #expect(face.isDone == isStale)
        #expect(face.symbol == (isStale ? "checkmark" : "book"))
    }

    @Test func aStalePausedTimerStaysPaused() {
        var timer = timer()
        timer.pause(at: at(60))

        #expect(face(timer, isStale: true).isDone == false)
    }

    // MARK: - The plan

    private let other = UUID()

    private var running: [TimerActivityPlan.Running] {
        [TimerActivityPlan.Running(id: "a", habitID: other), TimerActivityPlan.Running(id: "b", habitID: habitID)]
    }

    @Test func aNewTimerStartsAnActivityAndSendsTheOthersAway() {
        let plan = TimerActivityPlan(update: .start(timer(), symbol: "book"), running: running)

        #expect(plan.started == HabitTimerAttributes(timer: timer(), symbol: "book"))
        #expect(plan.state == HabitTimerAttributes.ContentState(timer: timer()))
        #expect(plan.dismissed == ["a", "b"])
        #expect(plan.followed.isEmpty)
        #expect(plan.finished.isEmpty)
    }

    @Test func aChangeMovesTheTimersActivityAndSendsTheOthersAway() {
        var paused = timer()
        paused.pause(at: at(60))

        let plan = TimerActivityPlan(update: .follow(paused), running: running)

        #expect(plan.followed == ["b"])
        #expect(plan.state == HabitTimerAttributes.ContentState(timer: paused))
        #expect(plan.dismissed == ["a"])
        #expect(plan.started == nil)
    }

    @Test func aChangeNeverStartsAnActivitySwipedAway() {
        let plan = TimerActivityPlan(update: .follow(timer()), running: [TimerActivityPlan.Running(id: "a", habitID: other)])

        #expect(plan.started == nil)
        #expect(plan.followed.isEmpty)
        #expect(plan.state == nil)
        #expect(plan.dismissed == ["a"])
    }

    @Test(arguments: [false, true])
    func theEndSendsEveryActivityAwayDoneOrAtOnce(isDone: Bool) {
        let plan = TimerActivityPlan(update: .end(isDone: isDone), running: running)

        #expect(plan.finished == (isDone ? ["a", "b"] : []))
        #expect(plan.dismissed == (isDone ? [] : ["a", "b"]))
        #expect(plan.started == nil)
    }

    // MARK: - The buttons

    @Test func pausaPausesTheRunningTimer() throws {
        let paused = try #require(TimerControl.change(timer(), paused: true, habitID: habitID.uuidString, now: at(60)))

        #expect(paused.state == .paused(secondsLeft: 1_140))
    }

    @Test func riprendiResumesThePausedTimer() throws {
        var timer = timer()
        timer.pause(at: at(60))

        let resumed = try #require(TimerControl.change(timer, paused: false, habitID: habitID.uuidString, now: at(600)))

        #expect(resumed.endDate == at(1_740))
    }

    @Test(arguments: [true, false])
    func aButtonLeftFromAnotherTimerChangesNothing(paused: Bool) {
        #expect(TimerControl.change(timer(), paused: paused, habitID: UUID().uuidString, now: at(60)) == nil)
        #expect(TimerControl.change(nil, paused: paused, habitID: habitID.uuidString, now: at(60)) == nil)
    }

    @Test func pausaOnAPausedTimerOrRiprendiOnARunningOneChangesNothing() {
        var paused = timer()
        paused.pause(at: at(60))

        #expect(TimerControl.change(paused, paused: true, habitID: habitID.uuidString, now: at(120)) == nil)
        #expect(TimerControl.change(timer(), paused: false, habitID: habitID.uuidString, now: at(120)) == nil)
    }

    @Test func pausaPastTheEndLeavesItToTheApp() {
        #expect(TimerControl.change(timer(), paused: true, habitID: habitID.uuidString, now: at(1_200)) == nil)
    }
}
