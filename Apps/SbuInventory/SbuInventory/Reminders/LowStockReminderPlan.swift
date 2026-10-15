import Foundation

/// When to remind you of what to buy again, and what to say.
///
/// One notification, at the next time you chose, naming up to three items. It is planned again whenever
/// the inventory changes or the app opens, so it never names something you already restocked, and it
/// never repeats on its own while you don't open the app.
nonisolated enum LowStockReminderPlan {
    /// - Parameters:
    ///   - lowItems: Names of the items at or below their minimum.
    ///   - minutesAfterMidnight: The time of day you chose.
    static func plan(lowItems: [String], minutesAfterMidnight: Int, now: Date, calendar: Calendar, locale: Locale) -> PlannedReminder? {
        guard !lowItems.isEmpty else { return nil }
        let time = DateComponents(hour: minutesAfterMidnight / 60, minute: minutesAfterMidnight % 60)
        guard let date = calendar.nextDate(after: now, matching: time, matchingPolicy: .nextTime) else { return nil }
        let names = lowItems.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        // Three names, or two and "e altri N" with N at least 2: never "e altri 1".
        let shown = Array(names.prefix(names.count > 3 ? 2 : 3))
        let listed = shown.formatted(.list(type: .and).locale(locale))
        let body: String
        if names.count > shown.count {
            body = String(localized: "\(shown.joined(separator: ", ")) e altri \(names.count - shown.count)", locale: locale)
        } else {
            body = listed
        }
        return PlannedReminder(title: String(localized: "Da ricomprare", locale: locale), body: body, date: date)
    }
}
