import Foundation

/// An app's privacy page on sbu.dev: Italian at `/privacy/<slug>`, English at `/en/privacy/<slug>`.
nonisolated enum SbuPrivacyPage {
    // ponytail: literal URL, always valid.
    private static let site = URL(string: "https://sbu.dev")!

    /// The page for an app, in English when `languageCode` is English and in Italian otherwise.
    /// - Parameters:
    ///   - slug: The app's sbu.dev slug, such as `habits`.
    ///   - languageCode: The language the settings are shown in, such as `it` or `en`.
    static func url(slug: String, languageCode: String?) -> URL {
        let isEnglish = languageCode?.hasPrefix("en") ?? false
        let components = isEnglish ? ["en", "privacy", slug] : ["privacy", slug]
        return components.reduce(site) { url, component in url.appending(component: component) }
    }
}
