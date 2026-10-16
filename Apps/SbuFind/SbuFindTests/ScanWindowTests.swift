import Foundation
import Testing
@testable import SbuFind

struct ScanWindowTests {
    @Test func aScanNeverStartedIsNotSettling() {
        #expect(!ScanWindow().isSettling(at: Advertisement.start))
    }

    @Test(arguments: [(0.0, true), (3.9, true), (ScanWindow.settling, false), (60.0, false)])
    func settlesForItsFirstSeconds(after seconds: TimeInterval, isSettling: Bool) {
        var window = ScanWindow()
        window.start(at: Advertisement.start)
        #expect(window.isSettling(at: Advertisement.start.addingTimeInterval(seconds)) == isSettling)
    }

    @Test func startingAgainRestartsTheSeconds() {
        var window = ScanWindow()
        window.start(at: Advertisement.start)
        window.start(at: Advertisement.start.addingTimeInterval(30))
        #expect(window.isSettling(at: Advertisement.start.addingTimeInterval(32)))
    }
}
