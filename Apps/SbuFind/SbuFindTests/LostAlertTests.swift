import Foundation
import Testing
@testable import SbuFind

struct LostAlertTests {
    let start = Advertisement.start

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    /// The switch's footnote and the notification say "15 secondi": they must match.
    @Test func theSilenceIsTheFifteenSecondsTheCopySays() {
        #expect(LostAlert.silenceBeforeAlert == 15)
    }

    @Test func startsWatching() {
        #expect(LostAlert(at: start).phase == .watching)
    }

    @Test(arguments: [
        (0.0, 15.0, false),
        (0.0, 15.01, true),
        (10.0, 24.0, false),
        (10.0, 26.0, true),
    ])
    func alertsAfterTheSilence(lastSeen: TimeInterval, now: TimeInterval, alerts: Bool) {
        var alert = LostAlert(at: start)
        let fired = alert.update(lastSeen: at(lastSeen), at: at(now))
        #expect(fired == alerts)
    }

    @Test func alertsOnlyOnceForOneLoss() {
        var alert = LostAlert(at: start)
        let fired1 = alert.update(lastSeen: start, at: at(20))
        #expect(fired1)
        let fired2 = alert.update(lastSeen: start, at: at(40))
        #expect(!fired2)
        let fired3 = alert.update(lastSeen: start, at: at(400))
        #expect(!fired3)
        #expect(alert.phase == .alerted)
    }

    @Test func hearingItAgainRearmsTheAlert() {
        var alert = LostAlert(at: start)
        let fired4 = alert.update(lastSeen: start, at: at(20))
        #expect(fired4)
        let fired5 = alert.update(lastSeen: at(21), at: at(21))
        #expect(!fired5)
        #expect(alert.phase == .watching)
        let fired6 = alert.update(lastSeen: at(21), at: at(30))
        #expect(!fired6)
        let fired7 = alert.update(lastSeen: at(21), at: at(37))
        #expect(fired7)
    }

    @Test func aDeviceNeverHeardIsLostAfterTheSilenceFromTheStart() {
        var alert = LostAlert(at: start)
        let fired8 = alert.update(lastSeen: nil, at: at(10))
        #expect(!fired8)
        let fired9 = alert.update(lastSeen: nil, at: at(16))
        #expect(fired9)
    }

    @Test func timeInTheBackgroundIsNotSilence() {
        var alert = LostAlert(at: start)
        let fired10 = alert.update(lastSeen: start, at: at(5))
        #expect(!fired10)
        alert.pause()
        let fired11 = alert.update(lastSeen: start, at: at(300))
        #expect(!fired11)
        #expect(alert.phase == .paused)

        alert.resume(at: at(300))
        // Back after five minutes: the device gets the full silence again to be heard.
        let fired12 = alert.update(lastSeen: start, at: at(310))
        #expect(!fired12)
        let fired13 = alert.update(lastSeen: start, at: at(316))
        #expect(fired13)
    }

    @Test func resumeOnlyWakesAPausedAlert() {
        var alert = LostAlert(at: start)
        alert.resume(at: at(100))
        // Not paused: the clock was not moved, so the silence since the start counts.
        let fired14 = alert.update(lastSeen: start, at: at(20))
        #expect(fired14)
    }

    @Test func heardDuringThePauseStillCountsAfterResume() {
        var alert = LostAlert(at: start)
        alert.pause()
        alert.resume(at: at(50))
        let fired15 = alert.update(lastSeen: at(60), at: at(70))
        #expect(!fired15)
        let fired16 = alert.update(lastSeen: at(60), at: at(76))
        #expect(fired16)
    }

    @Test func anAlertedDeviceIsNotRearmedByTheSameOldReading() {
        var alert = LostAlert(at: start)
        let fired17 = alert.update(lastSeen: at(3), at: at(19))
        #expect(fired17)
        let fired18 = alert.update(lastSeen: at(3), at: at(25))
        #expect(!fired18)
        #expect(alert.phase == .alerted)
    }
}
