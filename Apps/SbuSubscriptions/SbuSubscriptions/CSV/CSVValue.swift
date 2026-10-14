import Foundation

/// Reads the values of one field, forgiving of how people and apps write them.
nonisolated enum CSVValue {
    /// "12,99", "12.99", "€ 9,99", "$1,234.50", "1.234,56": the last of "." and "," is the decimal mark,
    /// unless it is followed by exactly three digits and is the only one, which makes it a thousands mark.
    static func price(_ text: String) -> Decimal? {
        let kept = text.filter { $0.isNumber || $0 == "." || $0 == "," || $0 == "-" }
        guard !kept.isEmpty, !kept.hasPrefix("-") else { return nil }
        let marks = kept.filter { $0 == "." || $0 == "," }
        var plain = kept
        if let last = kept.lastIndex(where: { $0 == "." || $0 == "," }) {
            let decimals = kept[kept.index(after: last)...]
            let isThousands = marks.count == 1 && decimals.count == 3
            plain = String(kept[..<last]).filter(\.isNumber) + (isThousands ? String(decimals) : "." + decimals)
        }
        return Decimal(string: plain, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func cycle(_ text: String) -> BillingCycle? {
        let words = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "_", with: " ").split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init)
        let joined = words.joined(separator: " ")
        switch joined {
        case "weekly", "settimanale", "week", "settimana": return .weekly
        case "monthly", "mensile", "month", "mese": return .monthly
        case "quarterly", "trimestrale": return .every(3, .month)
        case "yearly", "annual", "annually", "annuale", "year", "anno": return .yearly
        case "daily", "giornaliero", "day", "giorno": return .every(1, .day)
        case "once", "one time", "una tantum", "lifetime": return .once
        default: break
        }
        // "2 week", "every 2 weeks", "ogni 3 mesi"
        guard let number = words.lazy.compactMap({ Int($0) }).first, number > 0, let unitWord = words.last else { return nil }
        let unit: BillingUnit? = switch unitWord {
        case "day", "days", "giorno", "giorni": .day
        case "week", "weeks", "settimana", "settimane": .week
        case "month", "months", "mese", "mesi": .month
        case "year", "years", "anno", "anni": .year
        default: nil
        }
        return unit.map { .every(number, $0) }
    }

    /// ISO dates (the 1.0 wrote `toISOString()`), "yyyy-MM-dd", then day-first or month-first by the locale.
    static func date(_ text: String, locale: Locale, calendar: Calendar) -> Date? {
        let text = text.trimmingCharacters(in: .whitespaces)
        if let date = try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) { return calendar.startOfDay(for: date) }
        if let date = try? Date(text, strategy: Date.ISO8601FormatStyle()) { return calendar.startOfDay(for: date) }
        let parts = text.split(whereSeparator: { "-/.".contains($0) }).compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        let monthFirst = locale.region == .unitedStates
        let (year, month, day): (Int, Int, Int) = if parts[0] > 31 {
            (parts[0], parts[1], parts[2])
        } else if monthFirst {
            (parts[2], parts[0], parts[1])
        } else {
            (parts[2], parts[1], parts[0])
        }
        let components = DateComponents(year: year < 100 ? 2000 + year : year, month: month, day: day)
        guard components.isValidDate(in: calendar) else { return nil }
        return calendar.date(from: components)
    }

    static func flag(_ text: String) -> Bool {
        ["si", "sì", "yes", "true", "1", "y", "x"].contains(text.trimmingCharacters(in: .whitespaces).lowercased())
    }

    /// Writes a cycle the way `cycle(_:)` reads it back.
    static func text(for cycle: BillingCycle) -> String {
        switch cycle {
        case .once: "once"
        case .every(1, .week): "weekly"
        case .every(1, .month): "monthly"
        case .every(3, .month): "quarterly"
        case .every(1, .year): "yearly"
        case let .every(interval, unit): "\(interval) \(unit.rawValue)"
        }
    }
}
