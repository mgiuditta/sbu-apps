import WidgetKit

/// What the widget shows: the name of the TV its buttons go to, if any.
struct RemoteWidgetEntry: TimelineEntry {
    let date: Date
    let tvName: String?
}
