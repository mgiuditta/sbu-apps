import Foundation

/// Minutes asleep that count for a day, from the asleep periods Salute keeps (core, deep, REM or
/// unspecified). A sleep counts whole for the logical day you wake up in: the night from 23:00 to
/// 07:00 is the next day's, even when the day starts at 4 and the night crosses it. Periods less
/// than `wakeGap` apart are one sleep, so waking up for a while in the night does not split it;
/// periods logged twice (iPhone and Watch) count once.
nonisolated enum SleepTotal {
    /// Longer awake than this, and the next period is another sleep.
    static let wakeGap: TimeInterval = 2 * 60 * 60

    /// How far before the day to read: a sleep ending in the day started at most this long before.
    static let lookBack: TimeInterval = 24 * 60 * 60

    /// - Parameters:
    ///   - periods: The asleep periods from `day.start - lookBack` to `day.end`, in any order.
    ///   - day: The logical day.
    static func total(of periods: [DateInterval], wakingWithin day: DateInterval) -> Double {
        sleeps(in: periods)
            .filter { $0.end > day.start && $0.end <= day.end }
            .reduce(0) { $0 + $1.asleep } / 60
    }

    /// Joins overlapping periods, then periods closer than `wakeGap`, into sleeps.
    private static func sleeps(in periods: [DateInterval]) -> [(end: Date, asleep: TimeInterval)] {
        var sleeps: [(end: Date, asleep: TimeInterval)] = []
        for period in periods.sorted(by: { $0.start < $1.start }) {
            guard let last = sleeps.last, period.start.timeIntervalSince(last.end) < wakeGap else {
                sleeps.append((period.end, period.duration))
                continue
            }
            // Only the part after what is already counted adds to the sleep.
            let added = max(0, period.end.timeIntervalSince(max(period.start, last.end)))
            sleeps[sleeps.count - 1] = (max(last.end, period.end), last.asleep + added)
        }
        return sleeps
    }
}
