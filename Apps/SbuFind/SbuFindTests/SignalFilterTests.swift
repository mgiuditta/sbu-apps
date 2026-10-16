import Testing
@testable import SbuFind

struct SignalFilterTests {
    @Test(arguments: [
        ([-60], -60.0),
        ([-60, -70], -65.0),
        ([-70, -50, -60], -60.0),
        ([-90, -40, -41, -42], -41.5),
        ([-50, -50, -99, -50, -50], -50.0),
    ])
    func medianIsTheMiddleReading(readings: [Int], expected: Double) {
        #expect(SignalFilter.median(of: readings) == expected)
    }

    @Test func medianOfNothingIsZero() {
        #expect(SignalFilter.median(of: []) == 0)
    }

    @Test func startsEmptyThenTakesTheFirstReadingAsIs() {
        var filter = SignalFilter()
        #expect(filter.value == nil)
        #expect(filter.add(-63) == -63)
        #expect(filter.value == -63)
    }

    @Test(arguments: [-30, -60, -99])
    func aSteadySignalStaysPut(rssi: Int) {
        var filter = SignalFilter()
        for _ in 0..<50 {
            #expect(filter.add(rssi) == Double(rssi))
        }
    }

    @Test(arguments: [-35, -100, 0, -127])
    func oneSpikeIsIgnored(spike: Int) {
        var filter = SignalFilter()
        for _ in 0..<SignalFilter.window {
            filter.add(-70)
        }
        #expect(filter.add(spike) == -70)
        #expect(filter.add(-70) == -70)
    }

    @Test func twoSpikesInAWindowAreStillIgnored() {
        var filter = SignalFilter()
        for _ in 0..<SignalFilter.window {
            filter.add(-70)
        }
        filter.add(-40)
        #expect(filter.add(-40) == -70)
    }

    /// Walking closer: the value climbs towards the new level without overshooting it.
    @Test func aStepIsFollowedSmoothlyAndNeverOvershoots() throws {
        var filter = SignalFilter()
        for _ in 0..<SignalFilter.window {
            filter.add(-80)
        }
        var previous = -80.0
        for _ in 0..<40 {
            let value = filter.add(-50)
            #expect(value >= previous)
            #expect(value <= -50)
            previous = value
        }
        let settled = try #require(filter.value)
        #expect(abs(settled - -50) < 0.5)
    }

    @Test func aStepNeedsMoreThanHalfTheWindowToMoveTheValue() {
        var filter = SignalFilter()
        for _ in 0..<SignalFilter.window {
            filter.add(-80)
        }
        filter.add(-50)
        filter.add(-50)
        #expect(filter.value == -80)
        #expect(filter.add(-50) > -80)
    }

    /// The jitter of real readings: alternating ±8 dBm around -65 stays within a few dBm.
    @Test func jitterIsDamped() throws {
        var filter = SignalFilter()
        var values: [Double] = []
        for step in 0..<60 {
            values.append(filter.add(step.isMultiple(of: 2) ? -57 : -73))
        }
        let late = values.suffix(30)
        let spread = try #require(late.max()) - (try #require(late.min()))
        #expect(spread < 4)
        #expect(late.allSatisfy { abs($0 - -65) < 5 })
    }

    @Test func onlyTheLastWindowCounts() {
        var filter = SignalFilter()
        for _ in 0..<100 {
            filter.add(-90)
        }
        for _ in 0..<100 {
            filter.add(-45)
        }
        #expect(abs(filter.add(-45) - -45) < 0.001)
    }
}
