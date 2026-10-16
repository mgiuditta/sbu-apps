import Foundation
@testable import SbuShrink

/// Picked videos that are only names, and the probe that reads them.
nonisolated enum FakeVideos {
    /// A pending video named `name`, from Photos unless `fromFiles`; "BAD" names fail to load.
    static func pending(_ name: String, fromFiles: Bool = false) -> PendingVideo {
        PendingVideo(assetID: fromFiles ? nil : "asset/\(name)") {
            if name.contains("BAD") { throw CompressionError.unreadable }
            return URL(filePath: "/tmp/fake/\(name)")
        }
    }

    /// A one-minute 1080p phone video of `bytes` for every name; "NOPE" names are not videos.
    static func probe(bytes: Int64 = 128_460_000) -> ShrinkModel.Probe {
        { url in
            if url.lastPathComponent.contains("NOPE") { throw CompressionError.unreadable }
            return .phone(bytes: bytes)
        }
    }
}
