import WidgetKit

/// Reads the grid the watch app stored, with its pending taps; the app reloads the complication
/// whenever the grid or a tap changes it.
struct ComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let entry = ComplicationEntry.timeline(for: WatchStateStore.shared.load().shown, now: .now)[0]
        // The gallery shows real numbers when there are some, sample ones otherwise.
        completion(entry.today == nil && context.isPreview ? .sample : entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        let entries = ComplicationEntry.timeline(for: WatchStateStore.shared.load().shown, now: .now)
        completion(Timeline(entries: entries, policy: .never))
    }
}
