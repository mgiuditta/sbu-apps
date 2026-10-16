import Foundation
import Testing
@testable import SbuLibretto

struct NumberTextTests {
    @Test(arguments: [
        ("6", 6.0), ("7,5", 7.5), ("7.5", 7.5), (" 12 ", 12), ("0,25", 0.25), ("-3", -3), ("27,95", 27.95), ("060", 60),
    ])
    func readsNumbers(_ text: String, _ expected: Double) {
        #expect(NumberText.double(text, locale: Locale(identifier: "it_IT")) == expected)
        #expect(NumberText.double(text, locale: Locale(identifier: "en_US")) == expected)
    }

    @Test(arguments: ["", " ", "sei", "7,,5", "7.5.1", "1.000,5", "1,000.5", ",5", "5,", "+5", "5e3", "∞", "NaN", "7 5", "٣"])
    func refusesWhatIsNotPlainlyANumber(_ text: String) {
        #expect(NumberText.double(text, locale: Locale(identifier: "it_IT")) == nil)
    }

    @Test(arguments: [(7.5, "it_IT", "7,5"), (7.5, "en_US", "7.5"), (6, "it_IT", "6"), (1_000, "it_IT", "1000"), (7.256, "it_IT", "7,26")])
    func writesNumbersBackReadable(_ value: Double, _ locale: String, _ expected: String) {
        let text = NumberText.text(value, fractionDigits: 0...2, locale: Locale(identifier: locale))
        #expect(text == expected)
        #expect(NumberText.double(text, locale: Locale(identifier: locale)) != nil)
    }
}
