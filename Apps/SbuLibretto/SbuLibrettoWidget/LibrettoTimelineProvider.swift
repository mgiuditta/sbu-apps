import Foundation
import WidgetKit

/// Reads the snapshot the app wrote in the App Group, and plans one entry per midnight for a week,
/// so "Tra 3 giorni" turns into "Tra 2 giorni" without the app. The app reloads it after every change.
struct LibrettoTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LibrettoWidgetEntry {
        LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (LibrettoWidgetEntry) -> Void) {
        // The gallery shows the made-up libretto until the app has written the user's own.
        let snapshot = context.isPreview ? .sample(now: .now) : WidgetSnapshot.read(from: .appGroup) ?? .sample(now: .now)
        completion(LibrettoWidgetEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LibrettoWidgetEntry>) -> Void) {
        let snapshot = WidgetSnapshot.read(from: .appGroup)
        let entries = WidgetSnapshot.entryDates(from: .now, days: 7, calendar: .current).map { LibrettoWidgetEntry(date: $0, snapshot: snapshot) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
