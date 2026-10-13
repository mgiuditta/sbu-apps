import WidgetKit

/// Reads the free space now and the app's last snapshot; looks again every half hour.
struct SpaceProvider: TimelineProvider {
    /// Free space changes slowly; the app also asks for a redraw after each scan or deletion.
    private static let refresh: TimeInterval = 30 * 60

    func placeholder(in context: Context) -> SpaceEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (SpaceEntry) -> Void) {
        completion(context.isPreview ? .sample : current())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpaceEntry>) -> Void) {
        let entry = current()
        completion(Timeline(entries: [entry], policy: .after(entry.date.addingTimeInterval(Self.refresh))))
    }

    private func current() -> SpaceEntry {
        SpaceEntry(date: .now, storage: DeviceStorage.current(), freeableBytes: WidgetSnapshot.file?.load()?.freeableBytes)
    }
}
