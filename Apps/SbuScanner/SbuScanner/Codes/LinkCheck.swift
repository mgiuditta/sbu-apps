import Foundation

/// Where a link really goes, read from the link alone before it opens: no list online, no request.
nonisolated struct LinkCheck: Equatable, Sendable {
    nonisolated enum Warning: Equatable, Sendable, CaseIterable {
        /// http: what you send can be read on the way.
        case notEncrypted
        /// The host is written with look-alike letters from other alphabets (punycode, `xn--`).
        case lookAlike
        /// A bare IP address instead of a name.
        case ipAddress
        /// `https://bank.com@other.site`: everything before `@` is decoration, the site is after it.
        case hiddenHost
        /// A shortener: the real address shows only after it opens.
        case shortener
    }

    /// The whole host, lowercased, without `www.`.
    let host: String
    /// The part people recognise, such as `example.co.uk` in `login.example.co.uk`.
    let domain: String
    let warnings: [Warning]

    init?(_ url: URL) {
        guard let rawHost = url.host(percentEncoded: false)?.lowercased(), !rawHost.isEmpty else { return nil }
        let host = rawHost.hasPrefix("www.") ? String(rawHost.dropFirst(4)) : rawHost
        self.host = host
        let isIP = Self.isIPAddress(rawHost)
        domain = isIP ? host : Self.registrableDomain(host)

        var warnings: [Warning] = []
        if url.scheme?.lowercased() == "http" { warnings.append(.notEncrypted) }
        if host.split(separator: ".").contains(where: { $0.hasPrefix("xn--") }) || host.unicodeScalars.contains(where: { !$0.isASCII }) {
            warnings.append(.lookAlike)
        }
        if isIP { warnings.append(.ipAddress) }
        if url.user(percentEncoded: false) != nil { warnings.append(.hiddenHost) }
        if Self.shorteners.contains(domain) { warnings.append(.shortener) }
        self.warnings = warnings
    }

    // ponytail: a short list of the shorteners most found in printed codes, not the public suffix list.
    static let shorteners: Set<String> = [
        "bit.ly", "bitly.com", "tinyurl.com", "t.co", "goo.gl", "ow.ly", "is.gd", "buff.ly", "rebrand.ly",
        "cutt.ly", "shorturl.at", "tiny.cc", "rb.gy", "s.id", "qrco.de", "qr.codes", "t.ly", "short.gy", "lnkd.in",
    ]

    // ponytail: two-label suffixes for the countries we see most; a full public suffix list if domains come out wrong.
    private static let twoLabelSuffixes: Set<String> = [
        "co.uk", "org.uk", "ac.uk", "gov.uk", "com.au", "net.au", "org.au", "co.jp", "co.nz", "com.br", "com.mx",
        "co.in", "com.tr", "com.cn", "com.ar", "co.za", "com.sg", "com.hk", "co.kr", "gov.it", "edu.it",
    ]

    private static func registrableDomain(_ host: String) -> String {
        let labels = host.split(separator: ".")
        guard labels.count > 2 else { return host }
        let lastTwo = labels.suffix(2).joined(separator: ".")
        let count = twoLabelSuffixes.contains(lastTwo) ? 3 : 2
        return labels.suffix(count).joined(separator: ".")
    }

    private static func isIPAddress(_ host: String) -> Bool {
        if host.hasPrefix("[") || host.contains(":") { return true }
        let parts = host.split(separator: ".", omittingEmptySubsequences: false)
        return parts.count == 4 && parts.allSatisfy { UInt8($0) != nil }
    }
}
