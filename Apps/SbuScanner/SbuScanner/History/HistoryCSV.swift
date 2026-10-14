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

    private static func field(_ value: String) -> String {
        guard value.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline }) else { return value }
        return "\"" + value.replacing("\"", with: "\"\"") + "\""
    }
}
