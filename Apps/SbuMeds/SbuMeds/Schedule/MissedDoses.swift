import Foundation

/// The doses of past days that nobody marked, to write into the history as missed.
///
/// Written once, when the day is over: after that, changing the schedule never rewrites what
/// happened, as Medisafe's users ask after their schedules "broke" the past.
nonisolated enum MissedDoses {
    /// Days closed at most in one go, when the app was not opened for a long time.
    static let maxDays = 400

    /// The unmarked scheduled doses from the day after `closedThrough` to `yesterday`, both included.
    static func keys(
        for medicine: MedicineSnapshot,
        closedThrough: Day,
        yesterday: Day,
        calendar: Calendar
    ) -> [DoseKey] {
        guard closedThrough < yesterday else { return [] }
        let marked = Set(medicine.records.filter { !$0.isExtra && $0.mark != .moved }.map(\.key))
        var first = closedThrough.adding(days: 1, in: calendar)
        let span = first.days(to: yesterday, in: calendar)
        if span >= maxDays {
            first = yesterday.adding(days: -(maxDays - 1), in: calendar)
        }
        var keys: [DoseKey] = []
        var day = first
        while day <= yesterday {
            for time in medicine.schedule.times(on: day, calendar: calendar) {
                let key = DoseKey(medicineID: medicine.id, day: day, minutes: time.minutes)
                if !marked.contains(key) { keys.append(key) }
            }
            day = day.adding(days: 1, in: calendar)
        }
        return keys
    }
}
