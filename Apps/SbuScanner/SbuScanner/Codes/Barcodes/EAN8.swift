/// EAN-8, the short number on small products: 7 digits and a check digit, drawn as 67 modules.
nonisolated enum EAN8 {
    static func normalized(_ text: String) -> String? {
        GTIN.normalized(text, length: 8)
    }

    static func modules(_ code: String) -> [Bool] {
        let digits = code.compactMap(\.wholeNumberValue)
        guard digits.count == 8 else { return [] }
        let bits = "101" + digits[0...3].map { EAN13.lCodes[$0] }.joined() + "01010" + digits[4...7].map { EAN13.rCodes[$0] }.joined() + "101"
        return bits.map { $0 == "1" }
    }
}
