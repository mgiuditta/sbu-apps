import Foundation
import Testing
@testable import SbuFind

struct ProximityCueTests {
    @Test(arguments: [
        (0, Duration.milliseconds(1500)),
        (50, .milliseconds(825)),
        (100, .milliseconds(150)),
    ])
    func theGapShrinksFromSlowToFast(value: Int, gap: Duration) {
        let interval = ProximityCue.interval(for: Proximity(value: value))
        #expect(abs((interval - gap) / .milliseconds(1)) < 1)
    }

    @Test func closerNeverTicksSlower() {
        var previous = ProximityCue.interval(for: Proximity(value: 0))
        for value in 1...100 {
            let interval = ProximityCue.interval(for: Proximity(value: value))
            #expect(interval <= previous)
            #expect(interval >= ProximityCue.fastest)
            previous = interval
        }
    }

    @Test(arguments: [(0, 0.35), (100, 1.0)])
    func intensityGrowsToFull(value: Int, intensity: Double) {
        #expect(abs(ProximityCue.intensity(for: Proximity(value: value)) - intensity) < 0.0001)
    }

    @Test func intensityStaysInRange() {
        for value in 0...100 {
            let intensity = ProximityCue.intensity(for: Proximity(value: value))
            #expect((ProximityCue.softest...1).contains(intensity))
        }
    }

    private func tracked(silence: TimeInterval) -> TrackedDevice {
        TrackedDevice(
            device: NearbyDevice(id: Advertisement.testID(1), name: "Buds", kind: .earbuds, signal: -60, lastSeen: Advertisement.start),
            warmth: .hot,
            silence: silence
        )
    }

    @Test(arguments: [
        (true, false, true),
        (false, true, true),
        (true, true, true),
        (false, false, false),
    ])
    func ticksWithEitherSwitchOn(playsSound: Bool, vibrates: Bool, ticks: Bool) {
        #expect(ProximityCue.shouldTick(tracked: tracked(silence: 0), playsSound: playsSound, vibrates: vibrates) == ticks)
    }

    @Test func silentWhileTheDeviceIsNotHeard() {
        #expect(!ProximityCue.shouldTick(tracked: tracked(silence: 10), playsSound: true, vibrates: true))
        #expect(!ProximityCue.shouldTick(tracked: nil, playsSound: true, vibrates: true))
    }
}
