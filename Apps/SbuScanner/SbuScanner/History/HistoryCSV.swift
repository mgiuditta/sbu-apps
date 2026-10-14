import Foundation

/// The history as CSV: date, kind, code type, folder, favourite, content. Quotes doubled, as RFC 4180 asks.
nonisolated enum HistoryCSV {
    struct Row: Sendable {
        var date: Date
        var kind: String
        var symbology: String
        var folder: String
        var isFavorite: Bool
        var content: String
    }

    static func make(_ rows: [Row], header: [String]) -> String {
        let lines = [header] + rows.map { row in
            [row.date.ISO8601Format(), row.kind, row.symbology, row.folder, row.isFavorite ? "1" : "0", row.content]
        }
        return lines.map { $0.map(field).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
    }

    /// By Unicode scalar, not Character: "\r\n" is one Character and would hide its "\r". A leading
    /// whitespace or control character of any kind (no-break space, ideographic space, newline) is
    /// treated as a formula start, since spreadsheets may skip it to reach a sign; full-width signs too.
    private static func startsLikeAFormula(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first else { return false }
        if first.properties.isWhitespace || first.properties.generalCategory == .control { return true }
        return formulaSigns.contains(first)
    }

    private static let formulaSigns = Set("=+-@|%＝＋－＠".unicodeScalars)

    private static func field(_ value: String) -> String {
        // A code's text comes from anyone: a cell that starts like a formula would run in a spreadsheet,
        // so it gets a leading apostrophe and stays text (OWASP CSV injection).
        let value = startsLikeAFormula(value) ? "'" + value : value
        guard value.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline }) else { return value }
        return "\"" + value.replacing("\"", with: "\"\"") + "\""
    }
}
