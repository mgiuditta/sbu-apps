import Foundation
import Testing
@testable import SbuRemote

struct SSDPTests {
    @Test func searchRequestFollowsUPnP() throws {
        let text = try #require(String(data: SSDPMessage.search(target: "urn:samsung.com:device:RemoteControlReceiver:1"), encoding: .utf8))
        #expect(text.hasPrefix("M-SEARCH * HTTP/1.1\r\n"))
        #expect(text.contains("HOST: 239.255.255.250:1900\r\n"))
        #expect(text.contains("MAN: \"ssdp:discover\"\r\n"))
        #expect(text.contains("MX: 2\r\n"))
        #expect(text.contains("ST: urn:samsung.com:device:RemoteControlReceiver:1\r\n"))
        #expect(text.hasSuffix("\r\n\r\n"))
    }

    @Test func parsesASamsungReply() throws {
        let reply = """
        HTTP/1.1 200 OK\r
        CACHE-CONTROL: max-age=1800\r
        Location: http://192.168.1.20:7676/smp_15_\r
        ST: urn:samsung.com:device:RemoteControlReceiver:1\r
        USN: uuid:0ee6b280-00fa-1000-ba1c-a0b1c2d3e4f5::urn:samsung.com:device:RemoteControlReceiver:1\r
        \r

        """
        let response = try #require(SSDPResponse(Data(reply.utf8)))
        #expect(response.host == "192.168.1.20")
        #expect(response.brand == .samsung)
        #expect(response.uniqueServiceName?.hasPrefix("uuid:0ee6b280") == true)
    }

    @Test(arguments: [
        ("urn:lge-com:service:webos-second-screen:1", TVBrand.lg),
        ("URN:SCHEMAS-SONY-COM:SERVICE:SCALARWEBAPI:1", TVBrand.sony),
    ])
    func brandComesFromTheSearchTarget(target: String, brand: TVBrand) throws {
        let reply = "HTTP/1.1 200 OK\r\nLOCATION: http://10.0.0.5:1234/\r\nST: \(target)\r\n\r\n"
        #expect(try #require(SSDPResponse(Data(reply.utf8))).brand == brand)
    }

    @Test func ignoresRequestsAndErrors() {
        #expect(SSDPResponse(Data("M-SEARCH * HTTP/1.1\r\nST: ssdp:all\r\n\r\n".utf8)) == nil)
        #expect(SSDPResponse(Data("HTTP/1.1 404 Not Found\r\n\r\n".utf8)) == nil)
    }

    @Test func unknownTargetHasNoBrand() throws {
        let reply = "HTTP/1.1 200 OK\r\nLOCATION: http://10.0.0.5/\r\nST: roku:ecp\r\n\r\n"
        #expect(try #require(SSDPResponse(Data(reply.utf8))).brand == nil)
    }
}
