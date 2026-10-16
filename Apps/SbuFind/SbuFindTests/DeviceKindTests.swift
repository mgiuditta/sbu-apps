import Foundation
import Testing
@testable import SbuFind

struct DeviceKindTests {
    @Test(arguments: [
        ("AirPods Pro", DeviceKind.earbuds),
        ("AirPods di Giulia", .earbuds),
        ("AirPods Max", .headphones),
        ("Galaxy Buds2 Pro", .earbuds),
        ("Pixel Buds A", .earbuds),
        ("WF-1000XM5", .earbuds),
        ("WH-1000XM5", .headphones),
        ("Bose QuietComfort 45", .headphones),
        ("Beats Studio Pro", .headphones),
        ("Powerbeats Pro", .earbuds),
        ("Jabra Elite 85t", .earbuds),
        ("Soundcore Liberty 4", .earbuds),
        ("Apple Watch di Luca", .watch),
        ("Galaxy Watch6", .watch),
        ("Pixel Watch 2", .watch),
        ("Forerunner 255", .watch),
        ("Mi Band 8", .watch),
        ("Fitbit Charge 6", .watch),
        ("MacBook Air", .laptop),
        ("ThinkPad X1", .laptop),
        ("iPad di Anna", .tablet),
        ("Galaxy Tab S9", .tablet),
        ("iPhone di Marco", .phone),
        ("Galaxy S24", .phone),
        ("Pixel 8", .phone),
        ("JBL Flip 6", .speaker),
        ("JBL Charge 5", .speaker),
        ("UE BOOM 3", .speaker),
        ("HomePod", .speaker),
        ("Magic Keyboard", .keyboard),
        ("MX Master 3S", .mouse),
        ("Tile", .other),
        ("Oura", .other),
        ("LE-Bose", .other),
    ])
    func nameGivesTheKind(name: String, kind: DeviceKind) {
        #expect(DeviceKind(advertisement: .fixture(name: name)) == kind)
    }

    @Test(arguments: ["airpods pro", "AIRPODS PRO", "AirPods Pro"])
    func nameMatchIgnoresCase(name: String) {
        #expect(DeviceKind(advertisement: .fixture(name: name)) == .earbuds)
    }

    @Test func appleProximityPairingWithoutANameIsEarbuds() {
        let advertisement = Advertisement.fixture(name: nil, manufacturerData: Data([0x4C, 0x00, 0x07, 0x19, 0x01]))
        #expect(DeviceKind(advertisement: advertisement) == .earbuds)
    }

    @Test(arguments: [
        Data([0x4C, 0x00, 0x10, 0x05]),
        Data([0x4C, 0x00]),
        Data([0x75, 0x00, 0x07]),
    ])
    func otherManufacturerMessagesWithoutANameAreOther(data: Data) {
        #expect(DeviceKind(advertisement: .fixture(name: nil, manufacturerData: data)) == .other)
    }

    @Test(arguments: ["180D", "180d"])
    func heartRateServiceWithoutANameIsAWatch(uuid: String) {
        #expect(DeviceKind(advertisement: .fixture(name: nil, serviceUUIDs: ["1812", uuid])) == .watch)
    }

    @Test func aNameWinsOverManufacturerData() {
        let advertisement = Advertisement.fixture(name: "MacBook Air", manufacturerData: Data([0x4C, 0x00, 0x07]))
        #expect(DeviceKind(advertisement: advertisement) == .laptop)
    }

    @Test func nothingToGoOnIsOther() {
        #expect(DeviceKind(advertisement: .fixture(name: nil)) == .other)
    }

    @Test func everyKindHasItsOwnSymbol() {
        let symbols = DeviceKind.allCases.map(\.systemImage)
        #expect(Set(symbols).count == DeviceKind.allCases.count)
        #expect(DeviceKind.earbuds.systemImage == "airpods")
        #expect(DeviceKind.other.systemImage == "sensor")
    }
}
