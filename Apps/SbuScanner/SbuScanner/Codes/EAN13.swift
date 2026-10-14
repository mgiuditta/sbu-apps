/// EAN-13, the number on products in Europe: 12 digits and a check digit, drawn as 95 modules.
nonisolated enum EAN13 {
    /// The 13 digits for 12 typed (check digit added) or 13 typed (check digit verified); `nil` otherwise.
    static func normalized(_ text: String) -> String? {
        let digits = text.filter { !$0.isWhitespace && $0 != "-" }
        guard digits.allSatisfy(\.isASCII), digits.allSatisfy(\.isNumber) else { return nil }
        switch digits.count {
        case 12: return digits + String(checkDigit(digits))
        case 13: return checkDigit(String(digits.prefix(12))) == digits.last?.wholeNumberValue ? digits : nil
        default: return nil
        }
    }

    /// Weights 1 and 3 alternating from the left, then the step up to the next ten.
    static func checkDigit(_ twelve: String) -> Int {
        let sum = twelve.compactMap(\.wholeNumberValue).enumerated().reduce(0) { total, item in
            total + item.element * (item.offset.isMultiple(of: 2) ? 1 : 3)
        }
        return (10 - sum % 10) % 10
    }

    /// The 95 modules (true = bar) of a normalized code.
    static func modules(_ code: String) -> [Bool] {
        let digits = code.compactMap(\.wholeNumberValue)
        guard digits.count == 13 else { return [] }
        let parity = parities[digits[0]]
        var bits = "101"
        for (index, digit) in digits[1...6].enumerated() {
            let isG = parity[parity.index(parity.startIndex, offsetBy: index)] == "G"
            bits += isG ? gCodes[digit] : lCodes[digit]
        }
        bits += "01010"
        for digit in digits[7...12] { bits += rCodes[digit] }
        bits += "101"
        return bits.map { $0 == "1" }
    }

    private static let lCodes = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
    private static let gCodes = ["0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001", "0001001", "0010111"]
    private static let rCodes = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
    private static let parities = ["LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG", "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL"]
}
