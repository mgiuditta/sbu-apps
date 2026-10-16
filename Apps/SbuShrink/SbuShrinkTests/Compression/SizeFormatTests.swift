import Foundation
import Testing
@testable import SbuShrink

struct SizeFormatTests {
    private static let italian = Locale(identifier: "it_IT")
    private static let english = Locale(identifier: "en_US")

    @Test(arguments: [
        (Int64(0), "0 MB"),
        (-1, "0 MB"),
        (Int64.min, "0 MB"),
        (18_400_000, "18,4 MB"),
        (500_800_000, "500,8 MB"),
        (1_100_000_000, "1,1 GB"),
    ])
    func italianSizesReadAsInSettings(bytes: Int64, expected: String) {
        #expect(SizeFormat(locale: Self.italian).format(bytes) == expected)
    }

    @Test(arguments: [(Int64(0), "0 MB"), (18_400_000, "18.4 MB"), (1_100_000_000, "1.1 GB")])
    func englishSizesUseThePoint(bytes: Int64, expected: String) {
        #expect(SizeFormat(locale: Self.english).format(bytes) == expected)
    }

    @Test func theLargestSizeDoesNotCrash() {
        #expect(!SizeFormat(locale: Self.italian).format(.max).isEmpty)
    }

    @Test func localeReturnsAStyleForThatLocale() {
        #expect(SizeFormat().locale(Self.english).format(18_400_000) == "18.4 MB")
    }
}
