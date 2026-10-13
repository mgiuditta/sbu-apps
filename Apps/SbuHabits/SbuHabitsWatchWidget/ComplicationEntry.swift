import Foundation
import WidgetKit

/// What the complication shows at one moment: the Serie piena and today's habits done, or
/// nothing when the watch has no grid for the day.
struct ComplicationEntry: TimelineEntry {
    let date: Date
    /// `nil` before the first grid from the iPhone, or once its day is over.
    let today: ComplicationToday?

    /// For the gallery and the placeholder.
    static let sample = ComplicationEntry(date: .now, today: ComplicationToday(fullStreak: 12, done: 3, total: 5))

    /// The entries of a stored grid: today's now, then none once its day ends.
    static func timeline(for snapshot: WatchSnapshot?, now: Date) -> [ComplicationEntry] {
        guard let snapshot, snapshot.isCurrent(at: now) else { return [ComplicationEntry(date: now, today: nil)] }
        return [
            ComplicationEntry(date: now, today: ComplicationToday(snapshot)),
            ComplicationEntry(date: snapshot.nextDayStart, today: nil),
        ]
    }
}
