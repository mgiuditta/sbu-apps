import Foundation
import Testing
@testable import SbuFind

struct TrackedDeviceTests {
    private func tracked(silence: TimeInterval) -> TrackedDevice {
        TrackedDevice(
            device: NearbyDevice(id: Advertisement.testID(1), name: "Buds", kind: .earbuds, signal: -60, lastSeen: Advertisement.start),
            warmth: .hot,
            silence: silence
        )
    }

    @Test(arguments: [(0.0, false), (2.9, false), (TrackedDevice.lostAfter, false), (3.01, true), (120, true)])
    func lostAfterThreeSecondsOfSilence(silence: TimeInterval, isLost: Bool) {
        #expect(tracked(silence: silence).isLost == isLost)
    }

    @Test(arguments: [(0.0, 0), (3.99, 3), (8.5, 8), (65.2, 65)])
    func silenceCountsWholeSeconds(silence: TimeInterval, seconds: Int64) {
        #expect(tracked(silence: silence).silenceDuration == .seconds(seconds))
    }
}
