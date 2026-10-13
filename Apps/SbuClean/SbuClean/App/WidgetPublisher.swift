import WidgetKit

/// Writes the widget's snapshot to the App Group and asks the widget to redraw.
nonisolated enum WidgetPublisher {
    @Sendable
    static func publish(_ snapshot: WidgetSnapshot) {
        try? WidgetSnapshot.file?.save(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshot.widgetKind)
    }
}
