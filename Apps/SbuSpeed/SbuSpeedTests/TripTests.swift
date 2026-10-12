import Foundation
import Testing
@testable import SbuSpeed

struct TripTests {
    /// Records `samples` into a new trip.
    private func trip(_ samples: [SpeedSample]) -> Trip {
        var trip = Trip()
        for sample in samples {
            trip.record(sample)
        }
        return trip
    }

    @Test func steadyDriveAddsDistanceTimeAndAverage() {
        // 10 m/s for 5 s, one fix a second.
        let result = trip((0...5).map { .fix(at: Double($0), metersNorth: Double($0) * 10, speed: 10) })

        #expect(abs(result.distance - 50) < 0.5)
        #expect(result.movingTime == 5)
        #expect(abs(result.averageSpeed - 10) < 0.1)
        #expect(result.maxSpeed == 10)
    }

    @Test func topSpeedIgnoresUncertainSpeeds() {
        let result = trip([
            .fix(at: 0, speed: 12),
            .fix(at: 1, speed: 40, speedAccuracy: 8),
            .fix(at: 2, speed: -1, speedAccuracy: -1),
        ])

        #expect(result.maxSpeed == 12)
    }

    @Test func driftWhileStillAddsNoDistance() {
        // The position wanders by 3 m a second, but the speed says the iPhone is still.
        let result = trip((0...5).map { .fix(at: Double($0), metersNorth: Double($0 % 2) * 3, speed: 0.2) })

        #expect(result.distance == 0)
        #expect(result.movingTime == 0)
        #expect(result.averageSpeed == 0)
    }

    @Test func stopsDoNotLowerTheAverage() {
        let result = trip([
            .fix(at: 0, metersNorth: 0, speed: 10),
            .fix(at: 1, metersNorth: 10, speed: 10),
            .fix(at: 2, metersNorth: 10, speed: 0),
            .fix(at: 3, metersNorth: 10, speed: 0),
            .fix(at: 4, metersNorth: 20, speed: 10),
        ])

        #expect(abs(result.averageSpeed - 10) < 0.1)
    }

    @Test(arguments: [10.0, 11, 60, 600])
    func aGapLongerThanTenSecondsAddsNoDistance(gap: Double) {
        let result = trip([
            .fix(at: 0, metersNorth: 0, speed: 10),
            .fix(at: gap, metersNorth: 1_000, speed: 10),
            .fix(at: gap + 1, metersNorth: 1_010, speed: 10),
        ])

        let expected = gap <= Trip.maxGap ? 1_010.0 : 10.0
        #expect(abs(result.distance - expected) < 1)
    }

    @Test(arguments: [-1.0, 31, 200])
    func imprecisePositionsAddNoDistance(accuracy: Double) {
        let result = trip([
            .fix(at: 0, metersNorth: 0, speed: 10),
            .fix(at: 1, metersNorth: 10, speed: 10, horizontalAccuracy: accuracy),
            .fix(at: 2, metersNorth: 20, speed: 10),
        ])

        // The imprecise fix is skipped: the distance runs from the first to the third.
        #expect(abs(result.distance - 20) < 0.5)
    }

    @Test func newTripIsEmpty() {
        let trip = Trip()

        #expect(trip.isEmpty)
        #expect(trip.averageSpeed == 0)
    }
}
