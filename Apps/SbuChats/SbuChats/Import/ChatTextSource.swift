import Foundation

/// The text of an export, read line by line from a `.txt` file or from inside a `.zip`.
///
/// Never more than `maximumTextBytes` of text, however the file is built: a `.txt` larger than
/// that, a ZIP entry that declares more, or one that inflates past its declared size all stop the
/// import with `ImportFailure.tooLarge` before the text is read further.
nonisolated struct ChatTextSource {
    /// WhatsApp exports at most about 40,000 messages, a few megabytes: 200 MB is no chat.
    static let defaultMaximumTextBytes: UInt64 = 200 * 1024 * 1024

    private enum Origin {
        case file(URL)
        case zipEntry(ZipArchive, ZipEntry)
    }

    private let origin: Origin
    /// The bytes read from disk to go through the text once, for progress.
    let byteCount: UInt64
    let maximumTextBytes: UInt64
    let maximumLineBytes: Int

    private static let chunkSize = 64 * 1024

    /// A plain text export.
    init(textFile url: URL, maximumTextBytes: UInt64 = Self.defaultMaximumTextBytes,
         maximumLineBytes: Int = LineSplitter.defaultMaximumLineBytes) throws(ImportFailure) {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { throw .unreadableFile }
        guard UInt64(size) <= maximumTextBytes else { throw .tooLarge }
        origin = .file(url)
        byteCount = UInt64(size)
        self.maximumTextBytes = maximumTextBytes
        self.maximumLineBytes = maximumLineBytes
    }

    /// The chat inside an archive.
    init(archive: ZipArchive, entry: ZipEntry, maximumTextBytes: UInt64 = Self.defaultMaximumTextBytes,
         maximumLineBytes: Int = LineSplitter.defaultMaximumLineBytes) throws(ImportFailure) {
        guard entry.uncompressedSize <= maximumTextBytes,
              !ZipArchive.exceedsRatio(compressed: entry.compressedSize, uncompressed: entry.uncompressedSize)
        else { throw .tooLarge }
        origin = .zipEntry(archive, entry)
        byteCount = entry.compressedSize
        self.maximumTextBytes = maximumTextBytes
        self.maximumLineBytes = maximumLineBytes
    }

    /// Calls `line` for each line of the text, in order, and `progress` with the fraction read.
    func forEachLine(progress: (Double) -> Void, _ line: (String) throws -> Void) throws {
        var splitter = LineSplitter(maximumLineBytes: maximumLineBytes)
        let total = Double(max(byteCount, 1))
        var textBytes: UInt64 = 0
        func feed(_ chunk: Data) throws {
            textBytes += UInt64(chunk.count)
            // A file that grew since it was measured, or anything that slips past the checks above.
            guard textBytes <= maximumTextBytes else { throw ImportFailure.tooLarge }
            try splitter.feed(chunk, line: line)
        }
        do {
            switch origin {
            case let .file(url):
                let handle = try FileHandle(forReadingFrom: url)
                defer { try? handle.close() }
                var read: UInt64 = 0
                while let chunk = try handle.read(upToCount: Self.chunkSize), !chunk.isEmpty {
                    try Task.checkCancellation()
                    try feed(chunk)
                    read += UInt64(chunk.count)
                    progress(min(Double(read) / total, 1))
                }
            case let .zipEntry(archive, entry):
                try archive.read(entry, maximumSize: maximumTextBytes, progress: { progress(Double($0) / total) }, consume: feed)
            }
        } catch ZipError.tooLarge {
            throw ImportFailure.tooLarge
        }
        try splitter.finish(line: line)
    }
}
