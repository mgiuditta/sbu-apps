import Testing
@testable import SbuFind

struct ProximityTests {
    @Test(arguments: [
        (-127.0, 0),
        (-110.0, 0),
        (-100.0, 0),
        (-99.0, 2),
        (-94.0, 10),
        (-70.0, 50),
        (-64.0, 60),
        (-52.0, 80),
        (-46.0, 90),
        (-40.0, 100),
        (-30.0, 100),
        (0.0, 100),
    ])
    func signalMapsLinearlyAndClamps(rssi: Double, expected: Int) {
        #expect(Proximity(rssi: rssi).value == expected)
    }

    @Test(arguments: [(-70.4, 49), (-70.3, 50), (-69.7, 51)])
    func filteredReadingsRoundToTheNearestPoint(rssi: Double, expected: Int) {
        #expect(Proximity(rssi: rssi).value == expected)
    }

    @Test func integerAndDoubleReadingsAgree() {
        for rssi in -127...0 {
            #expect(Proximity(rssi: rssi) == Proximity(rssi: Double(rssi)))
        }
    }

    @Test func aStrongerSignalIsNeverFarther() {
        var previous = Proximity(rssi: -130)
        for rssi in -129...10 {
            let proximity = Proximity(rssi: rssi)
            #expect(proximity >= previous)
            #expect((0...100).contains(proximity.value))
            previous = proximity
        }
    }

    @Test func nonFiniteReadingsStayInRange() {
        #expect(Proximity(rssi: -Double.infinity).value == 0)
        #expect(Proximity(rssi: Double.infinity).value == 100)
        #expect(Proximity(rssi: Double.nan).value == 0)
    }
}
