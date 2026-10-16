import Foundation
import Testing
@testable import SbuFind

struct PlaceThrottleTests {
    private func asks(_ throttle: inout PlaceThrottle, _ device: Int, at seconds: TimeInterval) -> Bool {
        throttle.shouldAsk(for: Advertisement.testID(device), at: Advertisement.start.addingTimeInterval(seconds))
    }

    @Test(arguments: [(0.0, false), (59.9, false), (PlaceThrottle.interval, true), (300.0, true)])
    func asksAtMostOnceAMinutePerDevice(after seconds: TimeInterval, expected: Bool) {
        var throttle = PlaceThrottle()
        let first = asks(&throttle, 1, at: 0)
        let second = asks(&throttle, 1, at: seconds)
        #expect(first)
        #expect(second == expected)
    }

    @Test func eachDeviceHasItsOwnMinute() {
        var throttle = PlaceThrottle()
        let one = asks(&throttle, 1, at: 0)
        let two = asks(&throttle, 2, at: 0)
        #expect(one && two)
    }

    @Test func aRefusedAskDoesNotMoveTheMinute() {
        var throttle = PlaceThrottle()
        _ = asks(&throttle, 1, at: 0)
        _ = asks(&throttle, 1, at: 30)
        let later = asks(&throttle, 1, at: 60)
        #expect(later)
    }
}
