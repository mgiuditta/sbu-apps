import Foundation
import WidgetKit

/// One day of the widget: the app's snapshot, seen from that day, or nothing before the app has written one.
struct LibrettoWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}
