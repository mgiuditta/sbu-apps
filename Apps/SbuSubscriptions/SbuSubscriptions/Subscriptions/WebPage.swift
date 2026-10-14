import Foundation

/// A service's own website: only http and https, so a link from a typed field or an imported file can
/// never open another app or run anything (a `shortcuts:` or `tel:` URL, say). A bare "example.com" gets https.
nonisolated enum WebPage {
    static func url(_ text: String) -> URL? {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !text.contains(where: \.isWhitespace) else { return nil }
        // Any other scheme ("sms:", "mailto:", "shortcuts://") is refused rather than turned into a web address.
        if let scheme = text.firstMatch(of: /^([A-Za-z][A-Za-z0-9+.\-]*):/)?.1.lowercased(), scheme != "http", scheme != "https" {
            return nil
        }
        let candidate = text.contains("://") ? text : "https://" + text
        guard let url = URL(string: candidate), isWebPage(url) else { return nil }
        return url
    }

    static func isWebPage(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else { return false }
        return url.host()?.isEmpty == false
    }
}
