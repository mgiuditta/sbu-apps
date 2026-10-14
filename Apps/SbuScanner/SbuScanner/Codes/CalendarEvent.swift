import Foundation

/// An event from a `BEGIN:VEVENT` code (iCalendar).
nonisolated struct CalendarEvent: Equatable, Sendable {
    var title: String
    var start: Date
    var end: Date?
    var isAllDay: Bool
    var location: String
    var notes: String

    init(title: String, start: Date, end: Date? = nil, isAllDay: Bool = false, location: String = "", notes: String = "") {
        self.title = title
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
    }

    /// - Parameter timeZone: For times without a `Z`, which are local to whoever reads them.
    init?(code: String, timeZone: TimeZone = .current) {
        let upper = code.uppercased()
        guard upper.hasPrefix("BEGIN:VEVENT") || upper.hasPrefix("BEGIN:VCALENDAR") else { return nil }
        var fields: [String: String] = [:]
        for line in code.split(whereSeparator: \.isNewline) {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = line[..<colon].split(separator: ";").first.map { $0.uppercased() } ?? ""
            if fields[key] == nil { fields[key] = String(line[line.index(after: colon)...]) }
        }
        guard let startText = fields["DTSTART"], let start = Self.date(startText, timeZone: timeZone) else { return nil }
        self.init(
            title: fields["SUMMARY"].map(Self.unescape) ?? "",
            start: start,
            end: fields["DTEND"].flatMap { Self.date($0, timeZone: timeZone) },
            isAllDay: startText.count == 8,
            location: fields["LOCATION"].map(Self.unescape) ?? "",
            notes: fields["DESCRIPTION"].map(Self.unescape) ?? ""
        )
    }

    var code: String {
        var lines = ["BEGIN:VEVENT", "SUMMARY:\(Self.escape(title))"]
        if isAllDay {
            lines.append("DTSTART;VALUE=DATE:\(Self.stamp(start, format: "yyyyMMdd"))")
            if let end { lines.append("DTEND;VALUE=DATE:\(Self.stamp(end, format: "yyyyMMdd"))") }
        } else {
            lines.append("DTSTART:\(Self.stamp(start, format: "yyyyMMdd'T'HHmmss'Z'"))")
            if let end { lines.append("DTEND:\(Self.stamp(end, format: "yyyyMMdd'T'HHmmss'Z'"))") }
        }
        if !location.isEmpty { lines.append("LOCATION:\(Self.escape(location))") }
        if !notes.isEmpty { lines.append("DESCRIPTION:\(Self.escape(notes))") }
        lines.append("END:VEVENT")
        return lines.joined(separator: "\r\n")
    }

    /// `20261014`, `20261014T183000` (local) or `20261014T183000Z` (UTC).
    private static func date(_ text: String, timeZone: TimeZone) -> Date? {
        let digits = text.filter(\.isNumber)
        guard digits.count == 8 || digits.count == 14 else { return nil }
        func number(_ from: Int, _ length: Int) -> Int? {
            let start = digits.index(digits.startIndex, offsetBy: from)
            return Int(digits[start..<digits.index(start, offsetBy: length)])
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = text.hasSuffix("Z") ? .gmt : timeZone
        var components = DateComponents(year: number(0, 4), month: number(4, 2), day: number(6, 2))
        if digits.count == 14 {
            components.hour = number(8, 2)
            components.minute = number(10, 2)
            components.second = number(12, 2)
        }
        return calendar.date(from: components)
    }

    private static func stamp(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        // All-day dates are the user's own day; times travel in UTC.
        formatter.timeZone = format.hasSuffix("'Z'") ? .gmt : .current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private static func escape(_ value: String) -> String {
        value.replacing("\\", with: "\\\\").replacing(",", with: "\\,").replacing(";", with: "\\;").replacing("\n", with: "\\n")
    }

    private static func unescape(_ value: String) -> String {
        value.replacing("\\n", with: "\n").replacing("\\N", with: "\n").replacing("\\,", with: ",").replacing("\\;", with: ";").replacing("\\\\", with: "\\")
    }
}
