import Foundation

/// A TV's reply to an M-SEARCH: an HTTP-like status line and headers.
nonisolated struct SSDPResponse: Equatable, Sendable {
    /// Header values by lowercased name.
    let headers: [String: String]

    /// Parses a reply; `nil` when it is not a `200 OK` SSDP response.
    init?(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        let lines = text.components(separatedBy: "\r\n").flatMap { $0.components(separatedBy: "\n") }
        guard let status = lines.first, status.uppercased().hasPrefix("HTTP/1.1 200") else { return nil }

        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let name = line[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }
            headers[name] = value
        }
        self.headers = headers
    }

    /// The device description URL.
    var location: URL? { headers["location"].flatMap(URL.init(string:)) }

    /// The search target this reply answers.
    var searchTarget: String? { headers["st"] }

    /// Unique service name, stable for one TV.
    var uniqueServiceName: String? { headers["usn"] }

    /// The TV's address, from the description URL.
    var host: String? { location?.host() }

    /// The brand whose search target this reply answers.
    var brand: TVBrand? {
        guard let searchTarget else { return nil }
        return SSDPMessage.searchTargets.first { $0.value.caseInsensitiveCompare(searchTarget) == .orderedSame }?.key
    }
}
