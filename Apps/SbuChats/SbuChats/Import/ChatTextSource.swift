import Foundation

/// The text of an export, read line by line from a `.txt` file or from inside a `.zip`.
nonisolated struct ChatTextSource {
    private enum Origin {
        case file(URL)
        case zipEntry(ZipArchive, ZipEntry)
    }

    private let origin: Origin
    /// The bytes read from disk to go through the text once, for progress.
    let byteCount: UInt64

    private static let chunkSize = 64 * 1024

    /// A plain text export.
    init(textFile url: URL) throws(ImportFailure) {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { throw .unreadableFile }
        origin = .file(url)
        byteCount = UInt64(size)
    }

    /// The chat inside an archive.
    init(archive: ZipArchive, entry: ZipEntry) {
        origin = .zipEntry(archive, entry)
        byteCount = entry.compressedSize
    }

    /// Calls `line` for each line of the text, in order, and `progress` with the fraction read.
    func forEachLine(progress: (Double) -> Void, _ line: (String) throws -> Void) throws {
        var splitter = LineSplitter()
        let total = Double(max(byteCount, 1))
        switch origin {
        case let .file(url):
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            var read: UInt64 = 0
            while let chunk = try handle.read(upToCount: Self.chunkSize), !chunk.isEmpty {
                try Task.checkCancellation()
                try splitter.feed(chunk, line: line)
                read += UInt64(chunk.count)
                progress(Double(read) / total)
            }
        case let .zipEntry(archive, entry):
            try archive.read(entry, progress: { progress(Double($0) / total) }) { chunk in
                try splitter.feed(chunk, line: line)
            }
        }
        try splitter.finish(line: line)
    }
}
