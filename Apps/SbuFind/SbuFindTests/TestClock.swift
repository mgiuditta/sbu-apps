import Foundation
@testable import SbuFind

/// A clock the test moves by hand, starting at the fixtures' start.
final class TestClock {
    var now = Advertisement.start

    func read() -> Date {
        now
    }

    func advance(by seconds: TimeInterval) {
        now = now.addingTimeInterval(seconds)
    }
}
