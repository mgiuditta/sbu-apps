import Testing
@testable import SbuKit

struct LicenseTextTests {
    @Test func aParagraphsLinesJoinIntoOne() {
        let text = "The goals of the Open Font License are to stimulate worldwide\ndevelopment of collaborative font projects.\n\nThe OFL allows"
        #expect(SbuLicenseText.reflowed(text) == "The goals of the Open Font License are to stimulate worldwide development of collaborative font projects.\n\nThe OFL allows")
    }

    @Test(arguments: [
        "PREAMBLE\nThe goals",
        "-----\nSIL OPEN FONT LICENSE Version 1.1\n-----",
        "available with a FAQ at:\nhttps://scripts.sil.org/OFL",
        "conditions:\n1) Neither the Font Software",
    ])
    func breaksThatCarryMeaningStay(_ text: String) {
        #expect(SbuLicenseText.reflowed(text) == text)
    }

    @Test func trailingSpacesAreTrimmed() {
        #expect(SbuLicenseText.reflowed("can be bundled, embedded, \nredistributed") == "can be bundled, embedded, redistributed")
    }

    @Test func theBundledNoticeKeepsEveryWord() throws {
        let url = try #require(SbuFont.licenseURL)
        let notice = try String(contentsOf: url, encoding: .utf8)
        let words = { (text: String) in text.split(whereSeparator: \.isWhitespace) }
        #expect(words(SbuLicenseText.reflowed(notice)) == words(notice))
    }
}
