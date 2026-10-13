import Foundation

/// A licence notice laid out for a phone screen. Plain-text licences break their lines at about
/// 70 characters; on a narrower screen every one of those breaks leaves a short ragged line.
nonisolated enum SbuLicenseText {
    /// `text` with each paragraph's lines joined into one, so the screen wraps them. The breaks
    /// that carry meaning stay: blank lines, headings in capitals, rules of dashes, lines ending
    /// with a colon, and items that start a numbered point.
    static func reflowed(_ text: String) -> String {
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var result = ""
        for (index, raw) in lines.enumerated() {
            let line = raw.trimmingCharacters(in: .whitespaces)
            result += line
            guard index < lines.count - 1 else { break }
            let next = lines[index + 1].trimmingCharacters(in: .whitespaces)
            result += keepsBreak(after: line, before: next) ? "\n" : " "
        }
        return result
    }

    private static func keepsBreak(after line: String, before next: String) -> Bool {
        line.isEmpty || next.isEmpty
            || isRule(line) || isRule(next)
            || isHeading(line)
            || line.hasSuffix(":")
            || startsPoint(next)
    }

    private static func isRule(_ line: String) -> Bool {
        line.allSatisfy { $0 == "-" }
    }

    /// A line with letters, all of them capitals: PREAMBLE, DEFINITIONS.
    private static func isHeading(_ line: String) -> Bool {
        line.contains(where: \.isLetter) && line == line.uppercased()
    }

    /// "1) Neither the Font Software…"
    private static func startsPoint(_ line: String) -> Bool {
        line.range(of: #"^\d+\)"#, options: .regularExpression) != nil
    }
}
