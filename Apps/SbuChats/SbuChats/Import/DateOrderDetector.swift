import Foundation

/// Decides the date order of an export from all its message lines, without keeping them.
///
/// A number above 12 settles it (`15/10` can only be day-month). When every date fits both ways,
/// messages are chronological, so the order whose dates go backwards less often wins. Only a
/// real tie (a chat that lives within the first twelve days of months) falls back to the locale.
/// A stray line that looks like a header but reads no way, such as a pasted date in a message,
/// is tolerated up to one header in a hundred.
nonisolated struct DateOrderDetector {
    private struct Candidate {
        var rejected = 0
        var backwardSteps = 0
        var lastKey = Int.min
    }

    private var candidates: [DateOrder: Candidate] = Dictionary(uniqueKeysWithValues: DateOrder.allCases.map { ($0, Candidate()) })
    private(set) var headerCount = 0

    mutating func add(_ header: MessageHeader) {
        headerCount += 1
        for order in DateOrder.allCases {
            guard var candidate = candidates[order] else { continue }
            // A four-digit first number is a year; a year can't be anywhere else then.
            let yearFirst = header.firstFieldDigits == 4
            if yearFirst != (order == .yearMonthDay) || !order.accepts(header.dateFields) {
                candidate.rejected += 1
            } else {
                let date = order.components(of: header.dateFields)
                let key = date.year * 10_000 + date.month * 100 + date.day
                if key < candidate.lastKey { candidate.backwardSteps += 1 }
                candidate.lastKey = key
            }
            candidates[order] = candidate
        }
    }

    /// The order that reads the dates, or `nil` when none reads at least 99 in 100.
    /// - Parameter preferred: The tie-breaker, usually the device's own order.
    func order(preferring preferred: DateOrder) -> DateOrder? {
        let valid = DateOrder.allCases.compactMap { order -> (order: DateOrder, rejected: Int, backward: Int)? in
            guard let candidate = candidates[order], candidate.rejected * 100 <= headerCount else { return nil }
            return (order, candidate.rejected, candidate.backwardSteps)
        }
        guard let best = valid.min(by: { ($0.rejected, $0.backward) < ($1.rejected, $1.backward) }) else { return nil }
        let tied = valid.filter { $0.rejected == best.rejected && $0.backward == best.backward }.map(\.order)
        return tied.contains(preferred) ? preferred : best.order
    }

    /// The order of day, month and year in dates formatted for `locale`.
    static func preferredOrder(for locale: Locale) -> DateOrder {
        // 3 February 2001: the positions of "03" and "02" tell the order.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let sample = Date(timeIntervalSinceReferenceDate: 2_851_200)
        var style = Date.FormatStyle(date: .numeric, time: .omitted, locale: locale, calendar: calendar, timeZone: .gmt)
        style = style.year(.defaultDigits).month(.twoDigits).day(.twoDigits)
        let text = sample.formatted(style)
        guard let day = text.range(of: "03"), let month = text.range(of: "02") else { return .dayMonthYear }
        if let year = text.range(of: "2001"), year.lowerBound < month.lowerBound { return .yearMonthDay }
        return day.lowerBound < month.lowerBound ? .dayMonthYear : .monthDayYear
    }
}
