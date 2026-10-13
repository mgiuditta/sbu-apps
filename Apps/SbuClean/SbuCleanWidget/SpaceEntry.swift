import WidgetKit

/// One moment of the free-space widget.
struct SpaceEntry: TimelineEntry {
    let date: Date
    /// The iPhone's capacity and free space; `nil` when the system does not say.
    let storage: DeviceStorage?
    /// The space you can free from the app's last scan; `nil` before the app ran.
    let freeableBytes: Int64?

    static let sample = SpaceEntry(
        date: .now,
        storage: DeviceStorage(totalBytes: 128_000_000_000, availableBytes: 21_400_000_000),
        freeableBytes: 3_200_000_000
    )
}
