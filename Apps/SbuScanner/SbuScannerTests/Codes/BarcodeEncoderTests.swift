import Testing
@testable import SbuScanner

struct BarcodeEncoderTests {
    @Test(arguments: [("9638507", "96385074"), ("96385074", "96385074"), ("96385075", nil), ("123", nil)])
    func ean8(text: String, expected: String?) {
        #expect(EAN8.normalized(text) == expected)
    }

    @Test func ean8IsSixtySevenModules() {
        #expect(EAN8.modules("96385074").count == 67)
    }

    @Test(arguments: [("03600029145", "036000291452"), ("036000291452", "036000291452"), ("036000291453", nil)])
    func upcA(text: String, expected: String?) {
        #expect(UPCA.normalized(text) == expected)
    }

    /// UPC-E 0 425261 stands for UPC-A 0 42100 00526 with check digit 4.
    @Test(arguments: [("425261", "04252614"), ("0425261", "04252614"), ("04252614", "04252614"), ("04252615", nil), ("2425261", nil)])
    func upcE(text: String, expected: String?) {
        #expect(UPCE.normalized(text) == expected)
    }

    @Test func upcEExpandsByItsLastDigit() {
        #expect(UPCE.expanded("0425261") == "042100005260")
        #expect(UPCE.expanded("0123453") == "012300000450")
        #expect(UPCE.expanded("0123454") == "012340000050")
        #expect(UPCE.expanded("0123457") == "012345000070")
    }

    @Test func upcEIsFiftyOneModules() {
        #expect(UPCE.modules("04252614").count == 51)
    }

    @Test(arguments: [("1540014128876", "15400141288763"), ("15400141288763", "15400141288763"), ("15400141288760", nil)])
    func itf14(text: String, expected: String?) {
        #expect(ITF14.normalized(text) == expected)
    }

    @Test(arguments: [("sbu-42", "SBU-42"), ("A B", "A B"), ("sbu_42", nil), ("*", nil), ("", nil)])
    func code39(text: String, expected: String?) {
        #expect(Code39.normalized(text) == expected)
    }

    @Test(arguments: [("31117013206375", "31117013206375"), ("12-34$5", "12-34$5"), ("12A", nil)])
    func codabar(text: String, expected: String?) {
        #expect(Codabar.normalized(text) == expected)
    }

    @Test func widthPatternStartsWithABar() {
        #expect(WidthPattern.modules("nwn") == [true, false, false, false, true])
    }
}
