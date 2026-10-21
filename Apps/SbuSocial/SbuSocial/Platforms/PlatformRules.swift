import Foundation

/// What Sbu Social hides or blocks on a Platform. They ship inside the app, in `rules.json`, and
/// change only with an app update (ADR-0018). The route guard script applies the same rules to
/// the site's own navigation.
nonisolated struct PlatformRules: Codable, Hashable {
    /// The sites whose pages the browser opens, with their subdomains. Images, videos and scripts
    /// from CDNs load inside those pages; as a page of their own, anything else opens in Safari.
    var hosts: [String] = []
    /// Paths never opened: exactly this path, or every path under it when it ends in `*`,
    /// such as `/reels/` (the tab, while `/reels/ID` sent to you still opens) and `/explore*`.
    var blockedPaths: [String] = []
    /// Paths opened one at a time: from one of them you can't move to another, so a video sent
    /// to you plays alone and the swipe to the next one goes nowhere.
    var singlePaths: [String] = []
    /// A bare path sent elsewhere, such as Instagram's home to the feed of the people you follow.
    var redirects: [String: String] = [:]
    /// A path prefix replaced by another, keeping the rest: `/shorts/ID` becomes `/watch?v=ID`.
    var rewrites: [String: String] = [:]
    /// Hidden as soon as the page starts, before it is drawn.
    var css = ""
    /// Posts whose text carries one of these labels are hidden, such as "Sponsorizzato".
    var hiddenLabels: [String] = []
    /// The elements checked for `hiddenLabels`.
    var labelContainer = "article"
    /// A bundled `.js` file with the Platform's own behaviour, such as YouTube's ad removal; `nil` for none.
    var script: String?

    /// Every Platform's rules, read once from the app bundle.
    static let all: [Platform: PlatformRules] = {
        guard let url = Bundle.main.url(forResource: "rules", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rules = try? JSONDecoder().decode([String: PlatformRules].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: rules.compactMap { key, value in
            Platform(rawValue: key).map { ($0, value) }
        })
    }()

    /// Whether the browser may load this host: the host itself or any of its subdomains.
    func allows(host: String?) -> Bool {
        guard let host = host?.lowercased() else { return false }
        return hosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    /// Whether moving from `current` to `path` is refused.
    func blocks(path: String, from current: String) -> Bool {
        if blockedPaths.contains(where: { Self.matches(path, $0) }) { return true }
        return singlePaths.contains { current.hasPrefix($0) && path.hasPrefix($0) && path != current }
    }

    private static func matches(_ path: String, _ pattern: String) -> Bool {
        pattern.hasSuffix("*") ? path.hasPrefix(pattern.dropLast()) : path == pattern
    }

    /// Where a URL goes instead: a rewritten prefix, or the redirect of its bare path.
    func redirect(_ url: URL) -> URL? {
        let path = url.path.isEmpty ? "/" : url.path
        if let (prefix, target) = rewrites.first(where: { path.hasPrefix($0.key) }) {
            return URL(string: target + path.dropFirst(prefix.count), relativeTo: url)?.absoluteURL
        }
        guard url.query == nil, let target = redirects[path] else { return nil }
        return URL(string: target, relativeTo: url)?.absoluteURL
    }

    /// The source of `script`, read from the app bundle.
    var scriptSource: String? {
        script.flatMap { Bundle.main.url(forResource: $0, withExtension: "js") }
            .flatMap { try? String(contentsOf: $0, encoding: .utf8) }
    }
}
