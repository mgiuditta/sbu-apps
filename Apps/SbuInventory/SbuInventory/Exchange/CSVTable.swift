import Foundation

/// Comma-separated text split into rows of fields and back: quotes, doubled quotes, line breaks inside
/// quotes, a byte-order mark, and the semicolons spreadsheets use where the decimal mark is a comma.
nonisolated enum CSVTable {
    static func rows(_ text: String) -> [[String]] {
        var text = text
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
        let separator = separator(in: text)
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var iterator = Array(text).makeIterator()
        var pending: Character?
        while let character = pending ?? iterator.next() {
            pending = nil
            if inQuotes {
                if character == "\"" {
                    let next = iterator.next()
                    if next == "\"" { field.append("\"") } else { inQuotes = false; pending = next }
                } else {
                    field.append(character)
                }
                continue
            }
            switch character {
            case "\"" where field.isEmpty:
                inQuotes = true
            case separator:
                row.append(field)
                field = ""
            case "\n", "\r\n", "\r":
                row.append(field)
                field = ""
                if row.contains(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) { rows.append(row) }
                row = []
            default:
                field.append(character)
            }
        }
        row.append(field)
        if row.contains(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) { rows.append(row) }
        return rows
    }

    static func line(_ fields: [String]) -> String {
        fields.map { field in
            field.contains(where: { ",;\"\n\r".contains($0) }) ? "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\"" : field
        }.joined(separator: ",")
    }

    /// The separator of the header line: semicolons when there are more of them than commas outside quotes.
    private static func separator(in text: String) -> Character {
        let header = text.prefix { $0 != "\n" && $0 != "\r" && $0 != "\r\n" }
        var commas = 0, semicolons = 0, inQuotes = false
        for character in header {
            if character == "\"" { inQuotes.toggle() }
            if !inQuotes, character == "," { commas += 1 }
            if !inQuotes, character == ";" { semicolons += 1 }
        }
        return semicolons > commas ? ";" : ","
    }
}
