/// A category of the library the home lists with its count and size.
nonisolated enum MediaCategory: String, CaseIterable, Hashable, Codable, Sendable {
    case screenshots
    case screenRecordings
    case videos
    case livePhotos
}
