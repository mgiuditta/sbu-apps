import Foundation

/// Third-party ad and tracking domains, blocked in every Platform's browser with a content rule list (ADR-0018).
nonisolated enum TrackerRules {
    static let domains = [
        "doubleclick.net", "googlesyndication.com", "googleadservices.com", "google-analytics.com",
        "googletagmanager.com", "adservice.google.com", "scorecardresearch.com", "adnxs.com",
    ]

    /// The rule list in Safari content blocker syntax: any request to these domains or their subdomains.
    static var json: String {
        let rules = domains.map { domain in
            let host = domain.replacingOccurrences(of: ".", with: "\\.")
            return ["trigger": ["url-filter": "^https?://([^/]*\\.)?\(host)[/:]"], "action": ["type": "block"]]
        }
        // ponytail: encoding string dictionaries cannot fail.
        return (try? JSONEncoder().encode(rules)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
