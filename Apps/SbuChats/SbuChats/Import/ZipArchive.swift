import Compression
import Foundation

/// Reads a ZIP archive from its central directory and streams one entry at a time.
///
/// Enough of the format for chat exports: stored and DEFLATE entries, ZIP64 sizes and offsets,
/// UTF-8 or CP437 names. Nothing is read whole: an entry flows through `Compression` in chunks,
/// so a with-media export of several gigabytes costs only the chunk in memory.
nonisolated final class ZipArchive {
    let entries: [ZipEntry]
    private let handle: FileHandle
    private let fileSize: UInt64

    private static let chunkSize = 64 * 1024

    init(url: URL) throws(ZipError) {
        guard let handle = try? FileHandle(forReadingFrom: url) else { throw .notAnArchive }
        self.handle = handle
        do {
            fileSize = try handle.seekToEnd()
            entries = try Self.readCentralDirectory(handle: handle, fileSize: fileSize)
        } catch let error as ZipError {
            try? handle.close()
            throw error
        } catch {
            try? handle.close()
            throw .damaged
        }
    }

    deinit {
        try? handle.close()
    }

    /// Streams the decompressed bytes of `entry` to `consume`, chunk by chunk, and checks its CRC-32.
    /// - Parameters:
    ///   - progress: Called after each chunk with the compressed bytes read so far.
    ///   - consume: Receives each decompressed chunk, in order.
    func read(_ entry: ZipEntry, progress: (UInt64) -> Void = { _ in }, consume: (Data) throws -> Void) throws {
        let dataStart = try dataOffset(of: entry)
        guard dataStart + entry.compressedSize <= fileSize else { throw ZipError.damaged }
        try handle.seek(toOffset: dataStart)

        var crc = CRC32()
        var written: UInt64 = 0
        let sink: (Data) throws -> Void = { chunk in
            crc.update(chunk)
            written += UInt64(chunk.count)
            try consume(chunk)
        }

        switch entry.method {
        case .stored:
            try copy(entry.compressedSize, progress: progress, to: sink)
        case .deflated:
            // Apple's `.zlib` is raw DEFLATE (RFC 1951), the very stream ZIP stores.
            // The filter wants an escaping closure, but it only calls it inside `write` and `finalize`.
            try withoutActuallyEscaping(sink) { sink in
                let filter = try OutputFilter(.decompress, using: .zlib) { data in
                    if let data { try sink(data) }
                }
                try copy(entry.compressedSize, progress: progress) { try filter.write($0) }
                try filter.finalize()
            }
        case .unsupported:
            throw ZipError.unsupportedMethod
        }

        guard written == entry.uncompressedSize, crc.value == entry.crc32 else { throw ZipError.checksumMismatch }
    }

    private func copy(_ count: UInt64, progress: (UInt64) -> Void, to sink: (Data) throws -> Void) throws {
        var remaining = count
        while remaining > 0 {
            try Task.checkCancellation()
            let size = Int(min(UInt64(Self.chunkSize), remaining))
            guard let chunk = try handle.read(upToCount: size), !chunk.isEmpty else { throw ZipError.damaged }
            remaining -= UInt64(chunk.count)
            try sink(chunk)
            progress(count - remaining)
        }
    }

    /// The local header repeats name and extra field with their own lengths: the data starts after them.
    private func dataOffset(of entry: ZipEntry) throws -> UInt64 {
        try handle.seek(toOffset: entry.localHeaderOffset)
        guard let header = try handle.read(upToCount: 30), header.count == 30 else { throw ZipError.damaged }
        let bytes = LittleEndianBytes(header)
        guard bytes.uint32(at: 0) == 0x0403_4B50 else { throw ZipError.damaged }
        let nameLength = UInt64(bytes.uint16(at: 26))
        let extraLength = UInt64(bytes.uint16(at: 28))
        return entry.localHeaderOffset + 30 + nameLength + extraLength
    }

    // MARK: - Central directory

    private static func readCentralDirectory(handle: FileHandle, fileSize: UInt64) throws -> [ZipEntry] {
        // The end record is 22 bytes plus a comment of at most 65,535.
        let tailLength = min(fileSize, 22 + 65_535)
        try handle.seek(toOffset: fileSize - tailLength)
        guard let tailData = try handle.read(upToCount: Int(tailLength)) else { throw ZipError.notAnArchive }
        let tail = LittleEndianBytes(tailData)
        guard let end = tail.lastIndex(ofSignature: 0x0605_4B50, minimumLength: 22) else { throw ZipError.notAnArchive }

        var entryCount = UInt64(tail.uint16(at: end + 10))
        var directorySize = UInt64(tail.uint32(at: end + 12))
        var directoryOffset = UInt64(tail.uint32(at: end + 16))

        // ZIP64: a locator sits just before the end record and points to the 64-bit end record.
        let locator = end - 20
        if locator >= 0, tail.uint32(at: locator) == 0x0706_4B50 {
            let end64Offset = tail.uint64(at: locator + 8)
            guard end64Offset + 56 <= fileSize else { throw ZipError.damaged }
            try handle.seek(toOffset: end64Offset)
            guard let end64Data = try handle.read(upToCount: 56), end64Data.count == 56 else { throw ZipError.damaged }
            let end64 = LittleEndianBytes(end64Data)
            guard end64.uint32(at: 0) == 0x0606_4B50 else { throw ZipError.damaged }
            entryCount = end64.uint64(at: 32)
            directorySize = end64.uint64(at: 40)
            directoryOffset = end64.uint64(at: 48)
        }

        guard directoryOffset + directorySize <= fileSize, directorySize < UInt64(Int32.max) else { throw ZipError.damaged }
        try handle.seek(toOffset: directoryOffset)
        guard let directoryData = try handle.read(upToCount: Int(directorySize)), directoryData.count == Int(directorySize) else {
            throw ZipError.damaged
        }
        let directory = LittleEndianBytes(directoryData)

        var entries: [ZipEntry] = []
        var cursor = 0
        for _ in 0 ..< entryCount {
            guard cursor + 46 <= directory.count, directory.uint32(at: cursor) == 0x0201_4B50 else { throw ZipError.damaged }
            let flags = directory.uint16(at: cursor + 8)
            let methodCode = directory.uint16(at: cursor + 10)
            let crc = directory.uint32(at: cursor + 16)
            var compressed = UInt64(directory.uint32(at: cursor + 20))
            var uncompressed = UInt64(directory.uint32(at: cursor + 24))
            let nameLength = Int(directory.uint16(at: cursor + 28))
            let extraLength = Int(directory.uint16(at: cursor + 30))
            let commentLength = Int(directory.uint16(at: cursor + 32))
            var offset = UInt64(directory.uint32(at: cursor + 42))
            let nameStart = cursor + 46
            guard nameStart + nameLength + extraLength + commentLength <= directory.count else { throw ZipError.damaged }

            let nameBytes = directory.slice(nameStart, length: nameLength)
            // Bit 11 says UTF-8; older tools wrote CP437, which reads fine as UTF-8 for ASCII names.
            let path = String(bytes: nameBytes, encoding: .utf8) ?? String(decoding: nameBytes, as: UTF8.self)

            // ZIP64 extra field: the 64-bit values of the fields set to 0xFFFFFFFF, in this order.
            var extra = nameStart + nameLength
            let extraEnd = extra + extraLength
            while extra + 4 <= extraEnd {
                let tag = directory.uint16(at: extra)
                let size = Int(directory.uint16(at: extra + 2))
                if tag == 0x0001 {
                    var field = extra + 4
                    if uncompressed == 0xFFFF_FFFF, field + 8 <= extraEnd { uncompressed = directory.uint64(at: field); field += 8 }
                    if compressed == 0xFFFF_FFFF, field + 8 <= extraEnd { compressed = directory.uint64(at: field); field += 8 }
                    if offset == 0xFFFF_FFFF, field + 8 <= extraEnd { offset = directory.uint64(at: field) }
                }
                extra += 4 + size
            }

            let method: ZipEntry.Method = if flags & 1 == 1 {
                .unsupported(methodCode)
            } else {
                switch methodCode {
                case 0: .stored
                case 8: .deflated
                default: .unsupported(methodCode)
                }
            }
            entries.append(ZipEntry(path: path, method: method, crc32: crc, compressedSize: compressed,
                                    uncompressedSize: uncompressed, localHeaderOffset: offset))
            cursor = extraEnd + commentLength
        }
        return entries
    }
}

/// Little-endian integers out of a byte buffer, without alignment assumptions.
private nonisolated struct LittleEndianBytes {
    private let bytes: [UInt8]

    init(_ data: Data) {
        bytes = [UInt8](data)
    }

    var count: Int { bytes.count }

    func uint16(at index: Int) -> UInt16 {
        UInt16(bytes[index]) | UInt16(bytes[index + 1]) << 8
    }

    func uint32(at index: Int) -> UInt32 {
        UInt32(uint16(at: index)) | UInt32(uint16(at: index + 2)) << 16
    }

    func uint64(at index: Int) -> UInt64 {
        UInt64(uint32(at: index)) | UInt64(uint32(at: index + 4)) << 32
    }

    func slice(_ start: Int, length: Int) -> ArraySlice<UInt8> {
        bytes[start ..< start + length]
    }

    /// The last offset where a 4-byte signature starts with at least `minimumLength` bytes after it.
    func lastIndex(ofSignature signature: UInt32, minimumLength: Int) -> Int? {
        var index = bytes.count - minimumLength
        while index >= 0 {
            if uint32(at: index) == signature { return index }
            index -= 1
        }
        return nil
    }
}
