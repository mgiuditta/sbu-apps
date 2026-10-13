import Foundation

/// A clock a test moves by hand, for a `HabitsModel`'s `now`.
final class TestClock {
    var now: Date

    init(_ now: Date) {
        self.now = now
    }

    func advance(by seconds: TimeInterval) {
        now = now.addingTimeInterval(seconds)
    }
}
