@testable import SbuShrink

nonisolated extension SourceVideo {
    /// A minute of iPhone 1080p at 30 fps in H.264, about 17 Mb/s with AAC stereo: 128 MB.
    static func phone(
        duration: Double = 60,
        size: PixelSize = PixelSize(width: 1920, height: 1080),
        frameRate: Double = 30,
        videoBitsPerSecond: Double = 17_000_000,
        audioBitsPerSecond: Double = 128_000,
        hasAudio: Bool = true,
        bytes: Int64? = nil,
        fileExtension: String = "MOV"
    ) -> SourceVideo {
        let streams = (videoBitsPerSecond + audioBitsPerSecond) * max(duration, 0) / 8
        return SourceVideo(
            duration: duration,
            size: size,
            frameRate: frameRate,
            videoBitsPerSecond: videoBitsPerSecond,
            audioBitsPerSecond: audioBitsPerSecond,
            hasAudio: hasAudio,
            bytes: bytes ?? Int64(streams.isFinite ? streams : 0),
            fileExtension: fileExtension
        )
    }
}
