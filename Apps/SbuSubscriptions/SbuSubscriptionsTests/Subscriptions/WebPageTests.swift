import Foundation
import Testing
@testable import SbuSubscriptions

struct WebPageTests {
    @Test(arguments: [("example.com", "https://example.com"), ("https://example.com/account", "https://example.com/account"), ("HTTP://example.com", "HTTP://example.com")])
    func webPagesAreKept(text: String, expected: String) {
        #expect(WebPage.url(text)?.absoluteString == expected)
    }

    @Test(arguments: ["shortcuts://run-shortcut?name=x", "tel:+390000", "javascript:alert(1)", "file:///etc/passwd", "sms:123", "mailto:a@b.c", "otherapp://do", "", "https://", "exa mple.com"])
    func anythingElseIsRefused(text: String) {
        #expect(WebPage.url(text) == nil)
    }
}
