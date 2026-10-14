import Testing
@testable import SbuScanner

struct EAN13Tests {
    @Test(arguments: [("400638133393", 1), ("800112086190", 0), ("978020137962", 4)])
    func checkDigit(twelve: String, expected: Int) {
        #expect(EAN13.checkDigit(twelve) == expected)
    }

    @Test func twelveDigitsGetTheirCheckDigit() {
        #expect(EAN13.normalized("400638133393") == "4006381333931")
        #expect(EAN13.normalized("4 006381 33393") == "4006381333931")
    }

    @Test(arguments: ["4006381333932", "40063813339", "40063813339a", "", "٤٠٠٦٣٨١٣٣٣٩٣"])
    func rejects(text: String) {
        #expect(EAN13.normalized(text) == nil)
    }

    @Test func ninetyFiveModulesWithGuards() {
        let modules = EAN13.modules("4006381333931")
        #expect(modules.count == 95)
        #expect(Array(modules.prefix(3)) == [true, false, true])
        #expect(Array(modules[45..<50]) == [false, true, false, true, false])
        #expect(Array(modules.suffix(3)) == [true, false, true])
    }
}
