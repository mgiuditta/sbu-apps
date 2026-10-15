import Foundation

/// The order of day, month and year in a file's dates. A four-digit first part is always year first.
nonisolated enum DateOrder: String, CaseIterable, Identifiable, Sendable {
    case yearMonthDay
    case dayMonthYear
    case monthDayYear

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .yearMonthDay: "Anno, mese, giorno"
        case .dayMonthYear: "Giorno, mese, anno"
        case .monthDayYear: "Mese, giorno, anno"
        }
    }

    /// The order the dates show: a part over 12 settles it, otherwise the phone's habit.
    static func detect(_ samples: [String], locale: Locale) -> DateOrder {
        let parts = samples.compactMap(numbers).filter { $0.count >= 3 }
        if parts.contains(where: { $0[0] > 31 }) { return .yearMonthDay }
        if parts.contains(where: { $0[0] > 12 }) { return .dayMonthYear }
        if parts.contains(where: { $0[1] > 12 }) { return .monthDayYear }
        return locale.region == .unitedStates ? .monthDayYear : .dayMonthYear
    }

    /// The day a text such as "2026-03-14", "14/03/2026" or "3/14/26 08:30" stands for, at noon so
    /// no time zone moves it to another day.
    func date(from text: String, calendar: Calendar) -> Date? {
        guard let parts = Self.numbers(text), parts.count >= 3 else { return nil }
        var year: Int, month: Int, day: Int
        if parts[0] > 31 {
            (year, month, day) = (parts[0], parts[1], parts[2])
        } else {
            switch self {
            case .yearMonthDay: (year, month, day) = (parts[0], parts[1], parts[2])
            case .dayMonthYear: (day, month, year) = (parts[0], parts[1], parts[2])
            case .monthDayYear: (month, day, year) = (parts[0], parts[1], parts[2])
            }
        }
        if year < 100 { year += 2000 }
        guard (1...12).contains(month), (1...31).contains(day), (1900...2200).contains(year) else { return nil }
        let components = DateComponents(year: year, month: month, day: day, hour: 12)
        guard let date = calendar.date(from: components),
              calendar.component(.day, from: date) == day else { return nil }
        return date
    }

    private static func numbers(_ text: String) -> [Int]? {
        let parts = text.split { !$0.isNumber }.prefix(3).compactMap { Int($0) }
        return parts.isEmpty ? nil : parts
    }
}
