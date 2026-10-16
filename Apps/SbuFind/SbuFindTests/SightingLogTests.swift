import Foundation
import Testing
@testable import SbuFind

struct SightingLogTests {
    @Test func startsEmpty() {
        #expect(SightingLog().sightings.isEmpty)
    }

    @Test func aNewerSightingReplacesTheOlder() {
        var log = SightingLog()
        log.record(.fixture(after: 0))
        log.record(.fixture(after: 60))
        #expect(log.sightings == [.fixture(after: 60)])
    }

    @Test func anOlderSightingIsIgnored() {
        var log = SightingLog()
        log.record(.fixture(after: 60))
        log.record(.fixture(after: 0))
        log.record(.fixture(after: 60))
        #expect(log.sightings == [.fixture(after: 60)])
    }

    /// Bluetooth names are not authenticated: a device saying the same name never moves yours.
    @Test func theSameNameUnderAnotherIdentifierIsKeptApart() {
        var log = SightingLog()
        log.record(.fixture(device: 1, after: 0))
        log.record(.fixture(device: 2, after: 30))
        #expect(Set(log.sightings.map(\.id)) == [Advertisement.testID(1), Advertisement.testID(2)])
        #expect(log.latest(id: Advertisement.testID(1))?.date == Advertisement.start)
    }

    @Test(arguments: [(-1.0, false), (0.0, true), (65.0, true), (500.0, true), (501.0, false), (5000.0, false)])
    func vaguePositionsAreNotKept(accuracy: Double, isKept: Bool) {
        var log = SightingLog()
        log.record(.fixture(accuracy: accuracy))
        #expect(log.sightings.isEmpty != isKept)
    }

    @Test func newestFirstAndCappedAtCapacity() {
        var log = SightingLog()
        for device in 1...(SightingLog.capacity + 10) {
            log.record(.fixture(device: device, name: "Tag \(device)", after: Double(device)))
        }
        #expect(log.sightings.count == SightingLog.capacity)
        #expect(log.sightings.first?.name == "Tag \(SightingLog.capacity + 10)")
        #expect(log.sightings.last?.name == "Tag 11")
        let dates = log.sightings.map(\.date)
        #expect(dates == dates.sorted(by: >))
    }

    @Test func latestIsByIdentifierOnly() {
        var log = SightingLog()
        log.record(.fixture(device: 1, name: "Buds Pro"))
        #expect(log.latest(id: Advertisement.testID(1))?.name == "Buds Pro")
        #expect(log.latest(id: Advertisement.testID(9)) == nil)
    }

    @Test func recentLeavesOutOldAndHeardDevices() {
        var log = SightingLog()
        log.record(.fixture(device: 1, name: "Old", after: 0))
        log.record(.fixture(device: 2, name: "Heard", after: 100))
        log.record(.fixture(device: 3, name: "Recent", after: 200))
        let recent = log.recent(since: Advertisement.start.addingTimeInterval(50), excluding: [Advertisement.testID(2)])
        #expect(recent.map(\.name) == ["Recent"])
    }

    @Test func removeAllEmptiesIt() {
        var log = SightingLog()
        log.record(.fixture())
        log.removeAll()
        #expect(log.sightings.isEmpty)
    }

    @Test func survivesEncoding() throws {
        var log = SightingLog()
        log.record(.fixture(device: 1, name: "A", kind: .watch))
        log.record(.fixture(device: 2, name: "B", kind: .speaker, after: 3))
        let decoded = try JSONDecoder().decode(SightingLog.self, from: JSONEncoder().encode(log))
        #expect(decoded == log)
    }
}
