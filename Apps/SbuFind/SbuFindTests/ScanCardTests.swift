import Foundation
import Testing
@testable import SbuFind

struct ScanCardTests {
    let start = Advertisement.start

    @Test func startsHidden() {
        #expect(!ScanCard().isVisible)
    }

    @Test func showsAtAScanStartAndClosesOnTap() {
        var card = ScanCard()
        card.show(at: start)
        #expect(card.isVisible)
        card.close()
        #expect(!card.isVisible)
    }

    @Test(arguments: [
        (0, 7.9, true),
        (1, 7.9, true),
        (1, ScanCard.autoHideAfter, false),
        (6, 30, false),
        (0, 30, true),
    ])
    func hidesByItselfOnlyWithDevicesAfterTheDelay(devices: Int, seconds: TimeInterval, staysVisible: Bool) {
        var card = ScanCard()
        card.show(at: start)
        card.update(at: start.addingTimeInterval(seconds), listedDevices: devices)
        #expect(card.isVisible == staysVisible)
    }

    @Test func showingAgainRestartsTheDelay() {
        var card = ScanCard()
        card.show(at: start)
        card.show(at: start.addingTimeInterval(20))
        card.update(at: start.addingTimeInterval(25), listedDevices: 3)
        #expect(card.isVisible)
        card.update(at: start.addingTimeInterval(28), listedDevices: 3)
        #expect(!card.isVisible)
    }

    @Test func aClosedCardStaysClosed() {
        var card = ScanCard()
        card.show(at: start)
        card.close()
        card.update(at: start.addingTimeInterval(1), listedDevices: 0)
        #expect(!card.isVisible)
    }
}
