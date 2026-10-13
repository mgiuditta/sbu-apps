import Photos

nonisolated extension MediaItem {
    /// The item for a PhotoKit asset; `nil` for audio and unknown kinds.
    init?(asset: PHAsset) {
        let kind: MediaKind
        switch asset.mediaType {
        case .image: kind = .photo
        case .video: kind = .video
        default: return nil
        }

        self.init(id: asset.localIdentifier, creationDate: asset.creationDate, modificationDate: asset.modificationDate, kind: kind)
        isScreenshot = asset.mediaSubtypes.contains(.photoScreenshot)
        isScreenRecording = asset.mediaSubtypes.contains(.videoScreenRecording)
        isLivePhoto = asset.mediaSubtypes.contains(.photoLive)
        isFavorite = asset.isFavorite
        hasAdjustments = asset.hasAdjustments
        pixelWidth = asset.pixelWidth
        pixelHeight = asset.pixelHeight
        duration = asset.duration
    }
}
