import Foundation
import Testing
@testable import SbuFind

struct DeviceRosterTests {
    @Test func aNewDeviceIsListedWithItsReading() throws {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1, name: "Buds Pro", rssi: -55))

        let device = try #require(roster.device(id: Advertisement.testID(1)))
        #expect(device.name == "Buds Pro")
        #expect(device.kind == .earbuds)
        #expect(device.signal == -55)
        #expect(device.lastSeen == Advertisement.start)
        #expect(roster.count == 1)
    }

    @Test(arguments: [0, 127, 1, -128])
    func aNewDeviceWithoutAValidReadingIsNotListed(rssi: Int) {
        var roster = DeviceRoster()
        roster.record(.fixture(rssi: rssi))
        #expect(roster.isEmpty)
    }

    @Test func anInvalidReadingKeepsAKnownDeviceAliveWithItsLastSignal() throws {
        var roster = DeviceRoster()
        roster.record(.fixture(rssi: -55))
        roster.record(.fixture(rssi: 127, after: 8))

        let device = try #require(roster.device(id: Advertisement.testID(1)))
        #expect(device.signal == -55)
        #expect(device.lastSeen == Advertisement.start.addingTimeInterval(8))
    }

    @Test func aNewReadingMovesTheFilteredSignal() throws {
        var roster = DeviceRoster()
        roster.record(.fixture(rssi: -80))
        roster.record(.fixture(rssi: -45, after: 1))
        // Median of -80 and -45 is -62,5; 30 % of the way from -80 is -74,75.
        let signal = try #require(roster.device(id: Advertisement.testID(1))?.signal)
        #expect(abs(signal - -74.75) < 0.0001)
    }

    @Test func oneSpikeDoesNotReorderTheList() {
        var roster = DeviceRoster()
        for step in 0..<5 {
            roster.record(.fixture(device: 1, name: "Vicino", rssi: -50, after: Double(step)))
            roster.record(.fixture(device: 2, name: "Lontano", rssi: -80, after: Double(step)))
        }
        roster.record(.fixture(device: 2, name: "Lontano", rssi: -35, after: 5))
        #expect(roster.devices(includingUnnamed: true).map(\.name) == ["Vicino", "Lontano"])
    }

    @Test func signalsAFractionApartSortByName() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1, name: "Beta", rssi: -60))
        roster.record(.fixture(device: 1, name: "Beta", rssi: -61, after: 1))
        roster.record(.fixture(device: 2, name: "Alfa", rssi: -60))
        // Beta is at -60,15: the same whole dBm as Alfa.
        #expect(roster.devices(includingUnnamed: true).map(\.name) == ["Alfa", "Beta"])
    }

    @Test func aNameArrivingLaterIsKeptAndSetsTheKind() throws {
        var roster = DeviceRoster()
        roster.record(.fixture(name: nil, rssi: -60))
        #expect(roster.device(id: Advertisement.testID(1))?.kind == .other)

        roster.record(.fixture(name: "Forerunner 255", rssi: -61, after: 1))
        roster.record(.fixture(name: nil, rssi: -62, after: 2))

        let device = try #require(roster.device(id: Advertisement.testID(1)))
        #expect(device.name == "Forerunner 255")
        #expect(device.kind == .watch)
    }

    @Test func aBareAdvertisementDoesNotUndoAGuess() {
        var roster = DeviceRoster()
        roster.record(.fixture(name: nil, manufacturerData: Data([0x4C, 0x00, 0x07])))
        roster.record(.fixture(name: nil, after: 1))
        #expect(roster.device(id: Advertisement.testID(1))?.kind == .earbuds)
    }

    @Test func anOlderPacketDoesNotMoveLastSeenBack() {
        var roster = DeviceRoster()
        roster.record(.fixture(after: 5))
        roster.record(.fixture(after: 3))
        #expect(roster.device(id: Advertisement.testID(1))?.lastSeen == Advertisement.start.addingTimeInterval(5))
    }

    @Test(arguments: [
        (0.0, true),
        (9.9, true),
        (DeviceRoster.staleInterval, true),
        (10.01, false),
        (60, false),
    ])
    func aSilentDeviceLeavesAfterTheStaleInterval(silence: TimeInterval, isKept: Bool) {
        var roster = DeviceRoster()
        roster.record(.fixture())
        roster.removeStale(at: Advertisement.start.addingTimeInterval(silence))
        #expect((roster.device(id: Advertisement.testID(1)) != nil) == isKept)
    }

    @Test func removeStaleKeepsTheDevicesStillTalking() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1))
        roster.record(.fixture(device: 2, after: 9))
        roster.removeStale(at: Advertisement.start.addingTimeInterval(15))
        #expect(roster.devices(includingUnnamed: true).map(\.id) == [Advertisement.testID(2)])
    }

    @Test func removeAllEmptiesIt() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1))
        roster.record(.fixture(device: 2))
        roster.removeAll()
        #expect(roster.isEmpty)
        #expect(roster.devices(includingUnnamed: true).isEmpty)
    }

    @Test func devicesAreSortedStrongestFirst() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1, name: "A", rssi: -80))
        roster.record(.fixture(device: 2, name: "B", rssi: -40))
        roster.record(.fixture(device: 3, name: "C", rssi: -60))
        #expect(roster.devices(includingUnnamed: true).map(\.name) == ["B", "C", "A"])
    }

    @Test func equalSignalsSortByNameThenNamedBeforeUnnamedThenByIdentifier() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 4, name: nil, rssi: -60))
        roster.record(.fixture(device: 3, name: nil, rssi: -60))
        roster.record(.fixture(device: 2, name: "Zeta", rssi: -60))
        roster.record(.fixture(device: 1, name: "alfa", rssi: -60))
        let ids = roster.devices(includingUnnamed: true).map(\.id)
        #expect(ids == [1, 2, 3, 4].map(Advertisement.testID))
    }

    @Test func numbersInNamesSortAsNumbers() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1, name: "Tag 10", rssi: -60))
        roster.record(.fixture(device: 2, name: "Tag 9", rssi: -60))
        #expect(roster.devices(includingUnnamed: true).map(\.name) == ["Tag 9", "Tag 10"])
    }

    @Test func unnamedDevicesAreLeftOutAndCounted() {
        var roster = DeviceRoster()
        roster.record(.fixture(device: 1, name: "Buds", rssi: -70))
        roster.record(.fixture(device: 2, name: nil, rssi: -40))
        roster.record(.fixture(device: 3, name: nil, rssi: -90))

        #expect(roster.devices(includingUnnamed: false).map(\.id) == [Advertisement.testID(1)])
        #expect(roster.devices(includingUnnamed: true).count == 3)
        #expect(roster.unnamedCount == 2)
        #expect(roster.count == 3)
    }

    @Test func theSameDeviceIsListedOnce() {
        var roster = DeviceRoster()
        for second in 0..<20 {
            roster.record(.fixture(rssi: -50 - second, after: Double(second) / 4))
        }
        #expect(roster.count == 1)
    }
}
