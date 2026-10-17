import Foundation

/// An app's pages on sbu.dev: Italian at `/privacy/<slug>`, English at `/en/privacy/<slug>`.
nonisolated enum SbuPrivacyPage {
    // ponytail: literal URL, always valid.
    private static let site = URL(string: "https://sbu.dev")!

    /// The page for an app, in English when `languageCode` is English and in Italian otherwise.
    /// - Parameters:
    ///   - slug: The app's sbu.dev slug, such as `habits`.
    ///   - languageCode: The language the settings are shown in, such as `it` or `en`.
    static func url(slug: String, languageCode: String?) -> URL {
        page(["privacy", slug], languageCode: languageCode)
    }

    /// The app's own page, at `/apps/<slug>`: what Condividi l'app sends, so the link opens on the
    /// promises and the App Store badge.
    static func appURL(slug: String, languageCode: String?) -> URL {
        page(["apps", slug], languageCode: languageCode)
    }

    private static func page(_ path: [String], languageCode: String?) -> URL {
        let isEnglish = languageCode?.hasPrefix("en") ?? false
        let components = isEnglish ? ["en"] + path : path
        return components.reduce(site) { url, component in url.appending(component: component) }
    }
}
