import Foundation

/// What the user types to add a TV by hand: an IPv4 address or a local host name.
nonisolated enum HostInput {
    /// The address to connect to, or `nil` when the text is not one.
    /// Accepts `192.168.1.20` and `tv-soggiorno.local`; trims spaces and a pasted `http://`.
    static func normalized(_ text: String) -> String? {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for scheme in ["http://", "https://"] where value.hasPrefix(scheme) {
            value.removeFirst(scheme.count)
        }
        if let slash = value.firstIndex(of: "/") { value = String(value[..<slash]) }
        guard !value.isEmpty else { return nil }

        if isIPv4(value) { return value }
        // Something with only digits and dots that is not a valid IPv4 address is a typo, not a name.
        guard value.contains(where: \.isLetter) else { return nil }
        let allowed = CharacterSet.lowercaseLetters.union(.decimalDigits).union(CharacterSet(charactersIn: "-."))
        guard value.unicodeScalars.allSatisfy(allowed.contains), !value.hasPrefix("."), !value.hasPrefix("-") else { return nil }
        return value
    }

    private static func isIPv4(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return false }
        return parts.allSatisfy { part in
            guard (1...3).contains(part.count), part.allSatisfy(\.isNumber), let number = Int(part) else { return false }
            return number <= 255 && !(part.count > 1 && part.first == "0")
        }
    }
}
