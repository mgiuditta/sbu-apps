import Foundation
import Testing
@testable import SbuTidy

struct ChoreClockTests {
    private let now = Fixtures.now

    @Test(arguments: [0.0, 0.5, 1, 7, 365])
    func elapsedIsTheTimeSinceLastDone(days: Double) {
        let clock = ChoreClock(lastDone: Fixtures.daysAgo(days))
        #expect(clock.elapsed(at: now) == days * 86_400)
    }

    @Test(arguments: [1.0, 30, 10_000])
    func lastDoneInTheFutureNeverGivesNegativeTime(daysAhead: Double) {
        let clock = ChoreClock(lastDone: now.addingTimeInterval(daysAhead * 86_400))
        #expect(clock.elapsed(at: now) == 0)
    }

    @Test func pausedTimeDoesNotCount() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10))
        clock.pause(at: Fixtures.daysAgo(6))
        clock.resume(at: Fixtures.daysAgo(2))
        #expect(clock.elapsed(at: now) == 6 * 86_400)
        #expect(!clock.isPaused)
    }

    @Test func whilePausedElapsedStandsStill() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10))
        clock.pause(at: Fixtures.daysAgo(4))
        #expect(clock.elapsed(at: now) == 6 * 86_400)
        #expect(clock.elapsed(at: now.addingTimeInterval(30 * 86_400)) == 6 * 86_400)
    }

    @Test func twoPausesAddUp() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10))
        clock.pause(at: Fixtures.daysAgo(9))
        clock.resume(at: Fixtures.daysAgo(8))
        clock.pause(at: Fixtures.daysAgo(5))
        clock.resume(at: Fixtures.daysAgo(3))
        #expect(clock.pausedTime(at: now) == 3 * 86_400)
    }

    @Test func pausingTwiceKeepsTheFirstPause() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10))
        clock.pause(at: Fixtures.daysAgo(5))
        clock.pause(at: Fixtures.daysAgo(1))
        #expect(clock.pausedAt == Fixtures.daysAgo(5))
    }

    @Test func resumingWithoutAPauseChangesNothing() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(3))
        let before = clock
        clock.resume(at: now)
        #expect(clock == before)
    }

    @Test func resumingBeforeThePauseStartedAddsNoTime() {
        // The device's clock moved back while paused.
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10))
        clock.pause(at: now)
        clock.resume(at: Fixtures.daysAgo(3))
        #expect(clock.pausedSeconds == 0)
    }

    @Test func pauseBeforeLastDoneStartsAtLastDone() {
        var clock = ChoreClock(lastDone: now)
        clock.pause(at: Fixtures.daysAgo(5))
        #expect(clock.pausedAt == now)
    }

    @Test func aLaterCompletionStartsANewCycleAndEndsThePause() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(10), pausedAt: Fixtures.daysAgo(4), pausedSeconds: 3_600)
        clock.markDone(at: Fixtures.daysAgo(1), now: now)
        #expect(clock == ChoreClock(lastDone: Fixtures.daysAgo(1)))
    }

    @Test func anEarlierCompletionOnlyGoesInTheHistory() {
        let start = ChoreClock(lastDone: Fixtures.daysAgo(2), pausedSeconds: 60)
        var clock = start
        clock.markDone(at: Fixtures.daysAgo(5), now: now)
        #expect(clock == start)
    }

    @Test(arguments: [1.0, 365, 100_000])
    func aCompletionInTheFutureCountsAsNow(daysAhead: Double) {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(3))
        clock.markDone(at: now.addingTimeInterval(daysAhead * 86_400), now: now)
        #expect(clock.lastDone == now)
    }

    @Test func removingTheLatestCompletionGoesBackToThePreviousOne() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(1), pausedSeconds: 500)
        clock.restart(from: [Fixtures.daysAgo(8), Fixtures.daysAgo(4)], start: Fixtures.daysAgo(30))
        #expect(clock == ChoreClock(lastDone: Fixtures.daysAgo(4)))
    }

    @Test func removingTheOnlyCompletionGoesBackToTheStart() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(1))
        clock.restart(from: [], start: Fixtures.daysAgo(30))
        #expect(clock.lastDone == Fixtures.daysAgo(30))
    }

    @Test func removingAnOlderCompletionKeepsTheCycleAndItsPauses() {
        let start = ChoreClock(lastDone: Fixtures.daysAgo(1), pausedSeconds: 500)
        var clock = start
        clock.restart(from: [Fixtures.daysAgo(1)], start: Fixtures.daysAgo(30))
        #expect(clock == start)
    }

    @Test func aPauseThatStartedBeforeTheNewCycleMovesToItsStart() {
        var clock = ChoreClock(lastDone: Fixtures.daysAgo(1), pausedAt: Fixtures.daysAgo(1))
        clock.restart(from: [], start: now)
        #expect(clock.pausedAt == now)
    }

    @Test func negativeStoredPausesCountAsZero() {
        let clock = ChoreClock(lastDone: Fixtures.daysAgo(2), pausedSeconds: -1_000_000)
        #expect(clock.elapsed(at: now) == 2 * 86_400)
    }
}
