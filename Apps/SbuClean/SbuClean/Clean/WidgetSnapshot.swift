import Foundation

/// What the app tells the free-space widget: the space you can free from the last scan.
///
/// The widget reads the iPhone's free space itself; this is the only thing it cannot know.
/// Saved as a small file in the App Group the app and the widget share.
nonisolated struct WidgetSnapshot: Codable, Equatable, Sendable {
    static let appGroup = "group.dev.sbu.clean"
    static let widgetKind = "dev.sbu.clean.space"

    var freeableBytes: Int64
    var date: Date

    /// The shared file; `nil` where the App Group is missing, as in unsigned test builds.
    static var file: StoredFile<WidgetSnapshot>? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup).map {
            StoredFile(name: "widget.json", directory: $0)
        }
    }
}
