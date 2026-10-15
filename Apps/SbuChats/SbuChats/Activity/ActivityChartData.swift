import Foundation

/// The bars of one activity chart: every slot in order, empty ones included, split by series.
nonisolated struct ActivityChartData: Equatable, Sendable {
    /// A slot on the x axis.
    struct Slot: Identifiable, Equatable, Sendable {
        /// The slot value from `ActivityPoint`.
        let id: Int
        /// What the axis shows: "21", "lun", "mar 2024", "2024".
        let label: String
    }

    /// One bar segment.
    struct Bar: Identifiable, Equatable, Sendable {
        var id: String { "\(slot.id)-\(series.rawValue)" }
        let slot: Slot
        let series: ActivitySeries
        let count: Int
    }

    let slots: [Slot]
    let bars: [Bar]

    /// - Parameters:
    ///   - points: The counts for the axis, from `ChatStatistics.activity`.
    ///   - locale: Weekday and month names.
    init(axis: ActivityAxis, points: [ActivityPoint], calendar: Calendar = .current, locale: Locale = .current) {
        var calendar = calendar
        calendar.locale = locale
        let slotIDs: [Int]
        switch axis {
        case .hour:
            slotIDs = Array(0 ... 23)
        case .weekday:
            slotIDs = (0 ..< 7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
        case .month, .year:
            let present = points.map(\.slot)
            if let first = present.min(), let last = present.max() {
                slotIDs = Array(first ... last)
            } else {
                slotIDs = []
            }
        }
        let symbols = calendar.shortWeekdaySymbols
        slots = slotIDs.map { id in
            let label = switch axis {
            case .hour: Self.hourLabel(id, calendar: calendar, locale: locale)
            case .weekday: symbols[(id - 1) % symbols.count]
            case .month: Self.monthLabel(id, calendar: calendar, locale: locale)
            case .year: String(id)
            }
            return Slot(id: id, label: label)
        }
        let counts = Dictionary(points.map { ("\($0.slot)-\($0.series.rawValue)", $0.count) }, uniquingKeysWith: +)
        let series = Set(points.map(\.series)).sorted { $0.rawValue > $1.rawValue }
        bars = slots.flatMap { slot in
            series.map { series in Bar(slot: slot, series: series, count: counts["\(slot.id)-\(series.rawValue)"] ?? 0) }
        }
    }

    /// The slot with the most messages, all series together.
    var peak: Slot? {
        let totals = Dictionary(bars.map { ($0.slot.id, $0.count) }, uniquingKeysWith: +)
        guard let best = totals.max(by: { $0.value != $1.value ? $0.value < $1.value : $0.key > $1.key }), best.value > 0 else { return nil }
        return slots.first { $0.id == best.key }
    }

    /// The messages of a slot, all series together.
    func total(in slot: Slot) -> Int {
        bars.filter { $0.slot == slot }.map(\.count).reduce(0, +)
    }

    /// The messages of a slot for one series.
    func count(in slot: Slot, series: ActivitySeries) -> Int {
        bars.first { $0.slot == slot && $0.series == series }?.count ?? 0
    }

    /// "21" in Italian, "9 PM" in English (US): the hour as the locale writes it.
    private static func hourLabel(_ hour: Int, calendar: Calendar, locale: Locale) -> String {
        guard let date = calendar.date(from: DateComponents(year: 2001, month: 1, day: 1, hour: hour)) else { return String(hour) }
        var style = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        style = style.hour(.defaultDigits(amPM: .abbreviated))
        return date.formatted(style)
    }

    /// "mar 2024": abbreviated month and year; "Sep 26" would read as a day in English.
    private static func monthLabel(_ id: Int, calendar: Calendar, locale: Locale) -> String {
        let components = DateComponents(year: id / 12, month: id % 12 + 1, day: 1)
        guard let date = calendar.date(from: components) else { return String(id) }
        var style = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        style = style.month(.abbreviated).year(.defaultDigits)
        return date.formatted(style)
    }
}
