import Testing
@testable import SbuScanner

struct FieldListTests {
    @Test func firstValueOfARepeatedKeyWins() {
        #expect(FieldList.parse("MECARD:TEL:1;TEL:2;;", prefix: "MECARD:")["TEL"] == "1")
    }

    @Test func otherPrefixGivesNothing() {
        #expect(FieldList.parse("WIFI:S:x;;", prefix: "MECARD:").isEmpty)
    }

    @Test func makeSkipsEmptyValuesAndEscapes() {
        #expect(FieldList.make(prefix: "WIFI:", [("S", "a;b"), ("P", "")]) == #"WIFI:S:a\;b;;"#)
    }
}
