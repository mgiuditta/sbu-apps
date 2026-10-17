import Foundation
import Testing
@testable import SbuKit

/// Settings link to the app's privacy page in the language they are shown in.
struct PrivacyPageTests {
    @Test(arguments: [
        ("it", "https://sbu.dev/privacy/habits"),
        ("en", "https://sbu.dev/en/privacy/habits"),
        ("en-GB", "https://sbu.dev/en/privacy/habits"),
        ("fr", "https://sbu.dev/privacy/habits"),
    ])
    func pageFollowsLanguage(languageCode: String, expected: String) {
        #expect(SbuPrivacyPage.url(slug: "habits", languageCode: languageCode).absoluteString == expected)
    }

    @Test func missingLanguageFallsBackToItalian() {
        #expect(SbuPrivacyPage.url(slug: "level", languageCode: nil).absoluteString == "https://sbu.dev/privacy/level")
    }

    @Test(arguments: [
        ("it", "https://sbu.dev/apps/scanner"),
        ("en", "https://sbu.dev/en/apps/scanner"),
    ])
    func appPageFollowsLanguage(languageCode: String, expected: String) {
        #expect(SbuPrivacyPage.appURL(slug: "scanner", languageCode: languageCode).absoluteString == expected)
    }
}
