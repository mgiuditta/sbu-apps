/// Codabar, the barcode of libraries and blood banks: digits and `- $ : / . +`, between start and stop letters A.
nonisolated enum Codabar {
    static func normalized(_ text: String) -> String? {
        let body = text.filter { !$0.isWhitespace }
        return !body.isEmpty && body.allSatisfy({ patterns[$0] != nil && !"ABCD".contains($0) }) ? body : nil
    }

    /// Four bars and three spaces per character, with a narrow gap between characters.
    static func modules(_ code: String) -> [Bool] {
        ("A" + code + "A").compactMap { patterns[$0] }.map { WidthPattern.modules($0) }.joined(separator: [false]).map { $0 }
    }

    private static let patterns: [Character: String] = [
        "0": "nnnnnww", "1": "nnnnwwn", "2": "nnnwnnw", "3": "wwnnnnn", "4": "nnwnnwn",
        "5": "wnnnnwn", "6": "nwnnnnw", "7": "nwnnwnn", "8": "nwwnnnn", "9": "wnnwnnn",
        "-": "nnnwwnn", "$": "nnwwnnn", ":": "wnnnwnw", "/": "wnwnnnw", ".": "wnwnwnn", "+": "nnwnwnw",
        "A": "nnwwnwn", "B": "nwnwnnw", "C": "nnnwnww", "D": "nnnwwwn",
    ]
}
