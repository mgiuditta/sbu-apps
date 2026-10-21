import Foundation

/// A social site that Sbu Social opens in its filtered browser, with its own Rules.
nonisolated enum Platform: String, CaseIterable, Codable, Identifiable, Hashable {
    case instagram, youtube

    var id: Self { self }

    /// The site's own name, never translated.
    var name: String {
        switch self {
        case .instagram: "Instagram"
        case .youtube: "YouTube"
        }
    }

    /// Where the browser starts: the feed of the people you follow on Instagram.
    var homeURL: URL {
        switch self {
        case .instagram: URL(string: "https://www.instagram.com/?variant=following")!
        case .youtube: URL(string: "https://m.youtube.com/")!
        }
    }

    var rules: PlatformRules {
        PlatformRules.all[self] ?? PlatformRules()
    }
}
