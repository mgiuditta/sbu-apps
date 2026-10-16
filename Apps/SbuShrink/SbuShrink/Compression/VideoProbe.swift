import AVFoundation

/// Reads what the plan needs from a video file.
nonisolated enum VideoProbe {
    /// The source description of the file at `url`.
    /// - Throws: `CompressionError.unreadable` when it has no playable video track.
    @concurrent
    static func source(at url: URL) async throws -> SourceVideo {
        let asset = AVURLAsset(url: url)
        let bytes = Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        do {
            let (duration, isReadable) = try await asset.load(.duration, .isReadable)
            guard isReadable, let video = try await asset.loadTracks(withMediaType: .video).first else {
                throw CompressionError.unreadable
            }
            let (natural, transform, frameRate, videoRate) = try await video.load(.naturalSize, .preferredTransform, .nominalFrameRate, .estimatedDataRate)
            var audioRate = 0.0
            let audioTracks = try await asset.loadTracks(withMediaType: .audio)
            for track in audioTracks {
                audioRate += Double(try await track.load(.estimatedDataRate))
            }
            let shown = natural.applying(transform)
            let source = SourceVideo(
                duration: duration.seconds,
                size: PixelSize(width: Int(abs(shown.width).rounded()), height: Int(abs(shown.height).rounded())),
                frameRate: Double(frameRate),
                videoBitsPerSecond: Double(videoRate),
                audioBitsPerSecond: audioRate,
                hasAudio: !audioTracks.isEmpty,
                bytes: bytes,
                fileExtension: url.pathExtension
            )
            guard source.isUsable else { throw CompressionError.unreadable }
            return source
        } catch is CancellationError {
            throw CompressionError.cancelled
        } catch let error as CompressionError {
            throw error
        } catch {
            throw CompressionError.unreadable
        }
    }
}
