import Foundation
import Testing
@testable import SbuRemote

struct WakeOnLANTests {
    @Test func magicPacketIsSixFFThenTheMACSixteenTimes() throws {
        let packet = try #require(MagicPacket.packet(for: "A0:B1:C2:D3:E4:F5"))
        #expect(packet.count == 102)
        #expect(packet.prefix(6) == Data(repeating: 0xff, count: 6))
        let mac = Data([0xa0, 0xb1, 0xc2, 0xd3, 0xe4, 0xf5])
        for index in 0 ..< 16 {
            let start = 6 + index * 6
            #expect(packet[start ..< start + 6] == mac)
        }
    }

    @Test func noPacketWithoutAValidMAC() {
        #expect(MagicPacket.packet(for: "") == nil)
        #expect(MagicPacket.packet(for: "00:00:00:00:00:00") == nil)
    }

    @Test func broadcastOnlyWithTheEntitlement() {
        #expect(MagicPacket.destination(host: "192.168.1.20", isBroadcastAllowed: true) == "255.255.255.255")
        #expect(MagicPacket.destination(host: "192.168.1.20", isBroadcastAllowed: false) == "192.168.1.20")
        #expect(!NetworkFeatures.isMulticastEntitled)
    }

    @Test func powerStaysAvailableWhenTheTVIsOff() throws {
        let defaults = try #require(UserDefaults(suiteName: "WakeOnLANTests.\(UUID().uuidString)"))
        let store = TVStore(defaults: defaults)
        store.add(.sample)
        let session = RemoteSession(store: store) { DemoTVClient(tv: $0) }
        #expect(session.status == .unreachable)
        #expect(session.isAvailable(.power))
        #expect(!session.isAvailable(.volumeUp))
    }
}
