/// The code the user types from the TV: 6 hexadecimal characters (Android TV) or 4 digits (Sony).
nonisolated enum PairingCode {
    /// The text as the TV expects it, or `nil` until it is complete and valid.
    static func normalized(_ text: String, length: Int, isHexadecimal: Bool) -> String? {
        let cleaned = text.filter { !$0.isWhitespace }.uppercased()
        guard cleaned.count == length else { return nil }
        let valid = isHexadecimal ? cleaned.allSatisfy(\.isHexDigit) : cleaned.allSatisfy { $0.isASCII && $0.isNumber }
        return valid ? cleaned : nil
    }
}
