import Foundation
import Testing
@testable import SbuScanner

struct LinkCheckTests {
    private func check(_ text: String) throws -> LinkCheck {
        let url = try #require(URL(string: text))
        return try #require(LinkCheck(url))
    }

    @Test(arguments: [
        ("https://www.sbu.dev/apps", "sbu.dev", "sbu.dev"),
        ("https://login.example.co.uk/x", "login.example.co.uk", "example.co.uk"),
        ("https://a.b.example.com", "a.b.example.com", "example.com"),
        ("https://192.168.1.1/admin", "192.168.1.1", "192.168.1.1"),
    ])
    func hostAndDomain(link: String, host: String, domain: String) throws {
        let result = try check(link)
        #expect(result.host == host)
        #expect(result.domain == domain)
    }

    @Test func safeLinkHasNoWarnings() throws {
        #expect(try check("https://sbu.dev").warnings.isEmpty)
    }

    @Test(arguments: [
        ("http://example.com", LinkCheck.Warning.notEncrypted),
        ("https://xn--pple-43d.com", .lookAlike),
        ("https://192.168.1.1", .ipAddress),
        ("https://[::1]/", .ipAddress),
        ("https://mybank.com@evil.example", .hiddenHost),
        ("https://bit.ly/abc", .shortener),
    ])
    func warning(link: String, expected: LinkCheck.Warning) throws {
        #expect(try check(link).warnings.contains(expected))
    }

    @Test func hiddenHostShowsTheRealSite() throws {
        #expect(try check("https://mybank.com@evil.example/login").domain == "evil.example")
    }
}
