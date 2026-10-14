/// The check digit shared by EAN-8, UPC-A, EAN-13 and ITF-14: weights 3 and 1 alternating from the right.
nonisolated enum GTIN {
    static func checkDigit(_ body: String) -> Int {
        let sum = body.compactMap(\.wholeNumberValue).reversed().enumerated().reduce(0) { total, item in
            total + item.element * (item.offset.isMultiple(of: 2) ? 3 : 1)
        }
        return (10 - sum % 10) % 10
    }

    /// Digits only, spaces and dashes dropped; `nil` for anything else.
    static func digits(_ text: String) -> String? {
        let digits = text.filter { !$0.isWhitespace && $0 != "-" }
        return !digits.isEmpty && digits.allSatisfy({ $0.isASCII && $0.isNumber }) ? digits : nil
    }

    /// `length - 1` digits get their check digit; `length` digits must already have the right one.
    static func normalized(_ text: String, length: Int) -> String? {
        guard let digits = digits(text) else { return nil }
        switch digits.count {
        case length - 1: return digits + String(checkDigit(digits))
        case length: return checkDigit(String(digits.dropLast())) == digits.last?.wholeNumberValue ? digits : nil
        default: return nil
        }
    }
}
