import AVFoundation
import UniformTypeIdentifiers

/// The container of the compressed copy.
nonisolated enum OutputFormat: String, Codable, Sendable {
    case mov
    case mp4

    /// The container for a source: MP4 when asked, or when the source already is one
    /// (.mp4, .m4v); QuickTime otherwise, like the iPhone camera.
    init(sourceExtension: String, convertsToMP4: Bool) {
        let ext = sourceExtension.lowercased()
        self = convertsToMP4 || ext == "mp4" || ext == "m4v" ? .mp4 : .mov
    }

    var fileType: AVFileType {
        switch self {
        case .mov: .mov
        case .mp4: .mp4
        }
    }

    var fileExtension: String { rawValue }

    var contentType: UTType {
        switch self {
        case .mov: .quickTimeMovie
        case .mp4: .mpeg4Movie
        }
    }
}
