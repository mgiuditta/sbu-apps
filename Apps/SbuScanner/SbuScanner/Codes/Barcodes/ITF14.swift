/// ITF-14, the number on shipping cartons: 13 digits and a check digit, in Interleaved 2 of 5.
nonisolated enum ITF14 {
    static func normalized(_ text: String) -> String? {
        GTIN.normalized(text, length: 14)
    }

    /// Digits in pairs: the first in the bars, the second in the spaces between them.
    static func modules(_ code: String) -> [Bool] {
        let digits = code.compactMap(\.wholeNumberValue)
        guard digits.count == 14 else { return [] }
        var pattern = "nnnn"
        for pair in stride(from: 0, to: digits.count, by: 2) {
            let bars = Array(patterns[digits[pair]])
            let spaces = Array(patterns[digits[pair + 1]])
            for index in 0..<5 { pattern += String(bars[index]) + String(spaces[index]) }
        }
        pattern += "wnn"
        return WidthPattern.modules(pattern)
    }

    private static let patterns = ["nnwwn", "wnnnw", "nwnnw", "wwnnn", "nnwnw", "wnwnn", "nwwnn", "nnnww", "wnnwn", "nwnwn"]
}
