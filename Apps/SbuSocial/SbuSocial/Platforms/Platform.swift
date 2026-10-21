import Foundation

/// A social site that Sbu Social opens in its filtered browser, with its own Rules.
nonisolated enum Platform: String, CaseIterable, Codable, Identifiable, Hashable {
    case instagram, youtube, snapchat, x, tiktok, facebook, linkedin, reddit

    var id: Self { self }

    /// The site's own name, never translated.
    var name: String {
        switch self {
        case .instagram: "Instagram"
        case .youtube: "YouTube"
        case .snapchat: "Snapchat"
        case .x: "X"
        case .tiktok: "TikTok"
        case .facebook: "Facebook"
        case .linkedin: "LinkedIn"
        case .reddit: "Reddit"
        }
    }

    /// Where the browser starts: the feed of the people you follow where the site has one, the
    /// messages on TikTok and Snapchat.
    var homeURL: URL {
        let address = switch self {
        case .instagram: "https://www.instagram.com/?variant=following"
        case .youtube: "https://m.youtube.com/"
        case .snapchat: "https://web.snapchat.com/"
        case .x: "https://x.com/home"
        case .tiktok: "https://www.tiktok.com/messages"
        case .facebook: "https://m.facebook.com/"
        case .linkedin: "https://www.linkedin.com/feed/"
        case .reddit: "https://www.reddit.com/"
        }
        return URL(string: address)!
    }

    var rules: PlatformRules {
        PlatformRules.all[self] ?? PlatformRules()
    }
}
