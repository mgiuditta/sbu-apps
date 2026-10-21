import Foundation

/// What Sbu Social hides or blocks on a Platform. They ship inside the app, in `rules.json`, and
/// change only with an app update (ADR-0018). The route guard script applies the same rules to
/// the site's own navigation.
nonisolated struct PlatformRules: Codable, Hashable {
    /// The site and its CDNs: the browser loads nothing else in the main frame.
    var hosts: [String] = []
    /// Paths never opened, such as `/reels/` and `/explore/`.
    var blockedPaths: [String] = []
    /// Paths opened one at a time: from one of them you can't move to another, so a video sent
    /// to you plays alone and the swipe to the next one goes nowhere.
    var singlePaths: [String] = []
    /// A bare path sent elsewhere, such as Instagram's home to the feed of the people you follow.
    var redirects: [String: String] = [:]
    /// Hidden as soon as the page starts, before it is drawn.
    var css = ""
    /// Posts whose text carries one of these labels are hidden, such as "Sponsorizzato".
    var hiddenLabels: [String] = []
    /// The elements checked for `hiddenLabels`.
    var labelContainer = "article"

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
        if blockedPaths.contains(where: path.hasPrefix) { return true }
        return singlePaths.contains { current.hasPrefix($0) && path.hasPrefix($0) && path != current }
    }

    /// Where a URL goes instead, when its bare path has a redirect.
    func redirect(_ url: URL) -> URL? {
        guard url.query == nil, let target = redirects[url.path.isEmpty ? "/" : url.path] else { return nil }
        return URL(string: target, relativeTo: url)?.absoluteURL
    }
}
