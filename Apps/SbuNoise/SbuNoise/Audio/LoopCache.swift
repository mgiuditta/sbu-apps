import AVFAudio

/// The last few loops read into memory, so swiping back and forth or reopening a mix does not
/// decode the same file again. A minute of stereo audio is about 21 MB, so it keeps only a few.
final class LoopCache {
    private let capacity: Int
    private var buffers: [(url: URL, buffer: AVAudioPCMBuffer)] = []

    init(capacity: Int = 5) {
        self.capacity = capacity
    }

    /// The loop at `url`, read now if it is not in memory; the most recent stay.
    func buffer(for url: URL) throws -> AVAudioPCMBuffer {
        if let index = buffers.firstIndex(where: { $0.url == url }) {
            let entry = buffers.remove(at: index)
            buffers.append(entry)
            return entry.buffer
        }
        let buffer = try SoundEngine.loadLoop(url, padding: SoundEngine.loopPadding)
        buffers.append((url, buffer))
        if buffers.count > capacity { buffers.removeFirst() }
        return buffer
    }
}
