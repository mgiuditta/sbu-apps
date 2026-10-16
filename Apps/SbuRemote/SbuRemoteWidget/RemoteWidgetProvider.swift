import WidgetKit

/// Reads the last TV used from the App Group; changes only when the app changes it.
struct RemoteWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> RemoteWidgetEntry {
        RemoteWidgetEntry(date: .now, tvName: String(localized: "Soggiorno"))
    }

    func getSnapshot(in context: Context, completion: @escaping (RemoteWidgetEntry) -> Void) {
        let name = currentTVName() ?? (context.isPreview ? String(localized: "Soggiorno") : nil)
        completion(RemoteWidgetEntry(date: .now, tvName: name))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RemoteWidgetEntry>) -> Void) {
        completion(Timeline(entries: [RemoteWidgetEntry(date: .now, tvName: currentTVName())], policy: .never))
    }

    private func currentTVName() -> String? {
        let defaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
        return TVStore.load(from: defaults).current?.name
    }
}
