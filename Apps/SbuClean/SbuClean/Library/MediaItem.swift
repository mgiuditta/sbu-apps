import Foundation

/// One photo or video of the library, as the cleaner sees it.
///
/// It carries only what PhotoKit gives without loading the picture: the identifier, dates,
/// kind and flags. The size comes later, from `ItemSize`, because measuring is slower.
nonisolated struct MediaItem: Identifiable, Hashable, Sendable {
    /// The PhotoKit local identifier: stable across app updates.
    let id: String
    var creationDate: Date?
    var modificationDate: Date?
    var kind: MediaKind
    var isScreenshot = false
    var isScreenRecording = false
    var isLivePhoto = false
    var isFavorite = false
    var hasAdjustments = false
    var pixelWidth = 0
    var pixelHeight = 0
    /// Seconds, for videos.
    var duration: TimeInterval = 0
    /// `nil` until measured.
    var size: ItemSize?

    /// The size on disk, zero while not measured yet.
    var bytes: Int64 {
        size?.bytes ?? 0
    }

    var pixelCount: Int {
        pixelWidth * pixelHeight
    }

    /// Whether it belongs to one of the categories that are almost always safe to clear.
    func belongs(to category: MediaCategory) -> Bool {
        switch category {
        case .screenshots: isScreenshot
        case .screenRecordings: isScreenRecording
        case .videos: kind == .video
        case .livePhotos: isLivePhoto
        }
    }
}
