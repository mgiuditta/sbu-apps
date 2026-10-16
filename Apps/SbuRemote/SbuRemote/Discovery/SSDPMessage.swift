import Foundation

/// SSDP (UPnP 1.1) discovery messages: the M-SEARCH Sbu Remote sends and the replies TVs send back.
///
/// Sending to 239.255.255.250:1900 needs the multicast entitlement (#360), so `TVDiscovery`
/// only uses this when `NetworkFeatures.isMulticastEntitled` is on. Search targets come from
/// `research/1539090879/protocols.md`; the LG and Sony ones are still to verify on a real TV.
nonisolated enum SSDPMessage {
    static let multicastHost = "239.255.255.250"
    static let port: UInt16 = 1900

    /// Search target of each brand. Samsung's remote receiver, LG's second screen, Sony's Scalar web API.
    static let searchTargets: [TVBrand: String] = [
        .samsung: "urn:samsung.com:device:RemoteControlReceiver:1",
        .lg: "urn:lge-com:service:webos-second-screen:1",
        .sony: "urn:schemas-sony-com:service:ScalarWebAPI:1",
    ]

    /// The M-SEARCH request for one search target; `mx` is how many seconds TVs may wait to reply.
    static func search(target: String, mx: Int = 2) -> Data {
        let lines = [
            "M-SEARCH * HTTP/1.1",
            "HOST: \(multicastHost):\(port)",
            "MAN: \"ssdp:discover\"",
            "MX: \(mx)",
            "ST: \(target)",
            "",
            "",
        ]
        return Data(lines.joined(separator: "\r\n").utf8)
    }
}
