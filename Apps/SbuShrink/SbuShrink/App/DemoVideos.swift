import Foundation

/// The videos of the demo batch, for the UI tests, the screenshots and the previews: the sizes of
/// the original's own screenshots, with no file behind them.
nonisolated enum DemoVideos {
    /// A name with this in it fails in the demo compressor.
    static let brokenMarker = "BROKEN"

    static let sources: [String: SourceVideo] = [
        "IMG_1669.MOV": phone(seconds: 236, bytes: 500_800_000),
        "IMG_1620.MOV": phone(seconds: 52, bytes: 111_600_000),
        "IMG_4180.MOV": phone(seconds: 77, bytes: 163_500_000),
        "IMG_1756.MOV": phone(seconds: 98, bytes: 208_300_000),
        "IMG_2210.MOV": phone(seconds: 61, bytes: 129_400_000),
        // Already light: the copy would not be smaller.
        "IMG_0907.MP4": SourceVideo(duration: 30, size: PixelSize(width: 640, height: 360), frameRate: 24, videoBitsPerSecond: 150_000, audioBitsPerSecond: 64_000, hasAudio: true, bytes: 600_000, fileExtension: "MP4"),
        "IMG_BROKEN.MOV": phone(seconds: 40, bytes: 85_000_000),
    ]

    /// The first `count` of the regular videos, in the order of the original's screenshot.
    static func names(count: Int, scenario: String?) -> [String] {
        let regular = ["IMG_1669.MOV", "IMG_1620.MOV", "IMG_4180.MOV", "IMG_1756.MOV", "IMG_2210.MOV"]
        var names = Array(regular.prefix(max(count, 0)))
        if scenario == "mixed" {
            names += ["IMG_0907.MP4", "IMG_BROKEN.MOV"]
        }
        return names
    }

    /// A pending video whose "file" is a name in the work folder; nothing is copied.
    static func pending(_ name: String, delay: Duration = .zero) -> PendingVideo {
        PendingVideo(assetID: "demo/\(name)") {
            if delay > .zero {
                try await Task.sleep(for: delay)
            }
            return WorkFolder.root.appending(path: name)
        }
    }

    /// Reads a demo "file" by its name.
    @Sendable
    static func probe(_ url: URL) async throws -> SourceVideo {
        guard let source = sources[url.lastPathComponent] else { throw CompressionError.unreadable }
        return source
    }

    /// iPhone 1080p at 30 fps, the bit rate that makes `bytes` in `seconds`.
    private static func phone(seconds: Double, bytes: Int64) -> SourceVideo {
        SourceVideo(
            duration: seconds,
            size: PixelSize(width: 1920, height: 1080),
            frameRate: 30,
            videoBitsPerSecond: Double(bytes) * 8 / seconds - 128_000,
            audioBitsPerSecond: 128_000,
            hasAudio: true,
            bytes: bytes,
            fileExtension: "MOV"
        )
    }
}
