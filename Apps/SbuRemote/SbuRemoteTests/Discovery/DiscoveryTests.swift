import Foundation
import Network
import Testing
@testable import SbuRemote

struct DiscoveryTests {
    @Test(arguments: [
        (BonjourRecord(type: "_androidtvremote2._tcp", name: "Camera"), TVBrand?.some(.androidTV)),
        (BonjourRecord(type: "_airplay._tcp", name: "Soggiorno", txt: ["manufacturer": "Samsung"]), .samsung),
        (BonjourRecord(type: "_airplay._tcp", name: "Cucina", txt: ["Model": "LG OLED55C3"]), .lg),
        (BonjourRecord(type: "_airplay._tcp", name: "Studio", txt: ["manufacturer": "Sony"]), .sony),
        (BonjourRecord(type: "_airplay._tcp", name: "Apple TV", txt: ["model": "AppleTV14,1"]), nil),
    ])
    func bonjourBrand(record: BonjourRecord, brand: TVBrand?) {
        #expect(record.brand == brand)
    }

    @Test func aTVWithAndroidAndAirPlayShowsOnceAsAndroid() {
        let tvs = DiscoveredTV.merge(bonjour: [
            BonjourRecord(type: "_airplay._tcp", name: "Bravia", txt: ["manufacturer": "Sony"]),
            BonjourRecord(type: "_androidtvremote2._tcp", name: "Bravia"),
        ], ssdp: [])
        #expect(tvs.map(\.brand) == [.androidTV])
    }

    @Test func mergeSortsByNameAndSkipsUnknownReceivers() throws {
        let reply = try #require(SSDPResponse(Data("HTTP/1.1 200 OK\r\nLOCATION: http://192.168.1.30:3000/\r\nST: urn:lge-com:service:webos-second-screen:1\r\n\r\n".utf8)))
        let tvs = DiscoveredTV.merge(bonjour: [
            BonjourRecord(type: "_airplay._tcp", name: "Soggiorno", txt: ["manufacturer": "Samsung"]),
            BonjourRecord(type: "_airplay._tcp", name: "Apple TV"),
            BonjourRecord(type: "_androidtvremote2._tcp", name: "Camera"),
        ], ssdp: [reply])
        #expect(tvs.map(\.name) == ["192.168.1.30", "Camera", "Soggiorno"])
        #expect(tvs.first?.address == .host("192.168.1.30"))
    }

    @Test(arguments: [
        ("192.168.1.20", "192.168.1.20"),
        ("  10.0.0.7 ", "10.0.0.7"),
        ("http://192.168.1.20/", "192.168.1.20"),
        ("TV-Soggiorno.local", "tv-soggiorno.local"),
    ])
    func acceptsAddresses(text: String, host: String) {
        #expect(HostInput.normalized(text) == host)
    }

    @Test(arguments: ["", "192.168.1", "192.168.1.256", "192.168.01.2", "1.2.3.4.5", "tv soggiorno", "-tv"])
    func rejectsTypos(text: String) {
        #expect(HostInput.normalized(text) == nil)
    }

    @Test func policyDeniedMeansLocalNetworkIsOff() {
        #expect(LocalNetworkAccess.isDenied(.dns(-65570)))
        #expect(!LocalNetworkAccess.isDenied(.dns(-65537)))
        #expect(!LocalNetworkAccess.isDenied(.posix(.ECONNREFUSED)))
    }

    @Test func linkLocalIPv6LosesTheInterface() throws {
        let address = try #require(IPv6Address("fe80::1%en0"))
        #expect(AddressResolver.text(of: .ipv6(address)) == "fe80::1")
        #expect(AddressResolver.text(of: .ipv4(try #require(IPv4Address("192.168.1.2")))) == "192.168.1.2")
    }
}
