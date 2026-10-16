import Foundation
import Testing
@testable import SbuRemote

struct SecurityTests {
    @Test func fingerprintIsSHA256Hex() {
        #expect(CertificatePin.fingerprint(of: Data("abc".utf8)) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }

    @Test func pinAcceptsTheSameCertificateOnly() {
        #expect(CertificatePin.accepts(observed: "aa", pinned: nil))
        #expect(CertificatePin.accepts(observed: "aa", pinned: "aa"))
        #expect(!CertificatePin.accepts(observed: "bb", pinned: "aa"))
    }

    @Test func hexRoundTrip() throws {
        let data = Data([0x00, 0x0f, 0xa0, 0xff])
        #expect(data.hexString == "000fa0ff")
        #expect(Data(hexString: "000FA0ff") == data)
        #expect(Data(hexString: "abc") == nil)
        #expect(Data(hexString: "zz") == nil)
    }

    @Test(arguments: [
        ("a0:b1:c2:d3:e4:f5", "A0:B1:C2:D3:E4:F5"),
        ("A0-B1-C2-D3-E4-F5", "A0:B1:C2:D3:E4:F5"),
        ("a0b1c2d3e4f5", "A0:B1:C2:D3:E4:F5"),
    ])
    func macAddresses(text: String, normalized: String) {
        #expect(MACAddress.normalized(text) == normalized)
    }

    @Test(arguments: ["", "00:00:00:00:00:00", "a0:b1:c2:d3:e4", "a0 b1 c2 d3 e4 f5", "g0:b1:c2:d3:e4:f5"])
    func notMACAddresses(text: String) {
        #expect(MACAddress.normalized(text) == nil)
    }

    @Test func credentialRoundTripsThroughJSON() throws {
        let credential = TVCredential(token: "t", cookie: "auth=1", preSharedKey: nil, certificateSHA256: "ab")
        let decoded = try JSONDecoder().decode(TVCredential.self, from: JSONEncoder().encode(credential))
        #expect(decoded == credential)
    }
}
