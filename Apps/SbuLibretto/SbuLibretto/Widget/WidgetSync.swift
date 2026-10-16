import Foundation
import WidgetKit

/// Hands the widget the libretto's figures whenever they change.
enum WidgetSync {
    /// Writes the snapshot to the App Group and reloads the widget. Screenshots and UI tests run
    /// on made-up data and never touch the user's widget.
    static func publish(_ snapshot: WidgetSnapshot, mode: LaunchMode = .current, defaults: UserDefaults = .appGroup) {
        guard !mode.isDemo, WidgetSnapshot.read(from: defaults) != snapshot else { return }
        snapshot.write(to: defaults)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshot.widgetKind)
    }
}
