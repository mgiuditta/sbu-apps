/// UPC-E, the UPC-A with its zeros squeezed out: number system 0 or 1, six digits and the UPC-A check digit.
nonisolated enum UPCE {
    /// 6 digits (number system 0), 7 (with the number system) or 8 (with the check digit, verified).
    static func normalized(_ text: String) -> String? {
        guard let digits = GTIN.digits(text) else { return nil }
        let withSystem = digits.count == 6 ? "0" + digits : digits
        guard withSystem.count >= 7, withSystem.count <= 8, withSystem.first == "0" || withSystem.first == "1" else { return nil }
        let body = String(withSystem.prefix(7))
        let check = GTIN.checkDigit(String(expanded(body).dropLast()))
        if withSystem.count == 8, withSystem.last?.wholeNumberValue != check { return nil }
        return body + String(check)
    }

    /// The UPC-A this code stands for (11 digits and a placeholder check), for the check digit.
    static func expanded(_ body: String) -> String {
        let d = body.compactMap(\.wholeNumberValue).map(String.init)
        guard d.count == 7 else { return "" }
        let system = d[0]
        let middle: String = switch Int(d[6]) ?? 0 {
        case 0...2: d[1] + d[2] + d[6] + "0000" + d[3] + d[4] + d[5]
        case 3: d[1] + d[2] + d[3] + "00000" + d[4] + d[5]
        case 4: d[1] + d[2] + d[3] + d[4] + "00000" + d[5]
        default: d[1] + d[2] + d[3] + d[4] + d[5] + "0000" + d[6]
        }
        return system + middle + "0"
    }

    /// 51 modules: guard, six digits whose odd and even parity spell the check digit, end guard.
    static func modules(_ code: String) -> [Bool] {
        let digits = code.compactMap(\.wholeNumberValue)
        guard digits.count == 8 else { return [] }
        var parity = parities[digits[7]]
        // Number system 1 flips every parity.
        if digits[0] == 1 { parity = String(parity.map { $0 == "E" ? "O" : "E" }) }
        var bits = "101"
        for (index, digit) in digits[1...6].enumerated() {
            let isEven = parity[parity.index(parity.startIndex, offsetBy: index)] == "E"
            bits += isEven ? EAN13.gCodes[digit] : EAN13.lCodes[digit]
        }
        bits += "010101"
        return bits.map { $0 == "1" }
    }

    private static let parities = ["EEEOOO", "EEOEOO", "EEOOEO", "EEOOOE", "EOEEOO", "EOOEEO", "EOOOEE", "EOEOEO", "EOEOOE", "EOOEOE"]
}
