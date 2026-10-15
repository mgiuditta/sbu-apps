import Compression
import Foundation

/// Reads the files of a ZIP archive: this app's own, stored, and the deflated ones Files or Finder make
/// when you zip a folder again. Every file is checked against its CRC.
///
/// An archive picked for import is untrusted: every offset and size in it is checked against the
/// archive's real length, and the number of files, the bytes they unpack to and how much each one
/// expands are capped, so a damaged or hostile archive fails with an error instead of exhausting memory.
nonisolated enum ZipReader {
    enum Failure: Error, Equatable {
        case notAZip
        case damaged
        /// More files, more bytes or more expansion than an inventory can hold.
        case tooLarge
    }

    /// The caps an archive must stay within.
    struct Limits: Sendable {
        /// Files in the archive. An inventory with 8 photos per item for 5,000 items stays under it.
        var maxEntries = 50_000
        /// Bytes one file unpacks to: a 2048 px photo is well under 10 MB.
        var maxEntryBytes = 64 * 1024 * 1024
        /// Bytes all files unpack to together.
        var maxTotalBytes = 1024 * 1024 * 1024
        /// How many times a deflated file may expand; text rarely passes 20, a zip bomb passes 1,000.
        var maxRatio = 200

        static let standard = Limits()
    }

    /// Every file in the archive by name; folders are left out.
    static func files(in archive: Data, limits: Limits = .standard) throws(Failure) -> [String: Data] {
        guard let end = endOfCentralDirectory(in: archive),
              let count = archive.readLE(UInt16.self, at: end + 10).map(Int.init),
              let directoryOffset = archive.readLE(UInt32.self, at: end + 16).map(Int.init) else { throw .notAZip }
        guard count <= limits.maxEntries else { throw .tooLarge }
        guard directoryOffset <= end else { throw .damaged }

        var files: [String: Data] = [:]
        var totalBytes = 0
        var cursor = directoryOffset
        for _ in 0..<count {
            guard archive.readLE(UInt32.self, at: cursor) == 0x0201_4B50,
                  let method = archive.readLE(UInt16.self, at: cursor + 10),
                  let crc = archive.readLE(UInt32.self, at: cursor + 16),
                  let compressedSize = archive.readLE(UInt32.self, at: cursor + 20).map(Int.init),
                  let size = archive.readLE(UInt32.self, at: cursor + 24).map(Int.init),
                  let nameLength = archive.readLE(UInt16.self, at: cursor + 28).map(Int.init),
                  let extraLength = archive.readLE(UInt16.self, at: cursor + 30).map(Int.init),
                  let commentLength = archive.readLE(UInt16.self, at: cursor + 32).map(Int.init),
                  let localOffset = archive.readLE(UInt32.self, at: cursor + 42).map(Int.init),
                  let nameRange = range(start: cursor, offset: 46, length: nameLength, within: archive.count),
                  let next = sum(nameRange.upperBound, extraLength, commentLength), next <= archive.count
            else { throw .damaged }
            let name = String(decoding: archive[archive.startIndex + nameRange.lowerBound..<archive.startIndex + nameRange.upperBound], as: UTF8.self)
            cursor = next

            guard !name.hasSuffix("/") else { continue }
            guard method == 0 || method == 8 else { continue }
            guard size <= limits.maxEntryBytes else { throw .tooLarge }
            guard let newTotal = sum(totalBytes, size), newTotal <= limits.maxTotalBytes else { throw .tooLarge }
            totalBytes = newTotal

            guard archive.readLE(UInt32.self, at: localOffset) == 0x0403_4B50,
                  let localName = archive.readLE(UInt16.self, at: localOffset + 26).map(Int.init),
                  let localExtra = archive.readLE(UInt16.self, at: localOffset + 28).map(Int.init),
                  let dataStart = sum(localOffset, 30, localName, localExtra),
                  let dataRange = range(start: dataStart, offset: 0, length: compressedSize, within: archive.count)
            else { throw .damaged }
            let stored = archive[archive.startIndex + dataRange.lowerBound..<archive.startIndex + dataRange.upperBound]

            let data: Data
            if method == 0 {
                guard compressedSize == size else { throw .damaged }
                data = Data(stored)
            } else {
                // A deflated file that claims to expand far beyond any real photo or text is a bomb.
                guard size <= max(compressedSize, 1) * limits.maxRatio else { throw .tooLarge }
                data = try inflate(Data(stored), expectedSize: size)
            }
            guard CRC32.checksum(data) == crc else { throw .damaged }
            files[name] = data
        }
        return files
    }

    /// `start + offset ..< start + offset + length`, if it fits inside `count` bytes without overflowing.
    private static func range(start: Int, offset: Int, length: Int, within count: Int) -> Range<Int>? {
        guard start >= 0, offset >= 0, length >= 0,
              let lower = sum(start, offset), let upper = sum(lower, length), upper <= count else { return nil }
        return lower..<upper
    }

    /// The sum, or `nil` if it overflows.
    private static func sum(_ values: Int...) -> Int? {
        var total = 0
        for value in values {
            let (result, overflow) = total.addingReportingOverflow(value)
            if overflow { return nil }
            total = result
        }
        return total
    }

    private static func endOfCentralDirectory(in archive: Data) -> Int? {
        guard archive.count >= 22 else { return nil }
        // The record is 22 bytes plus a comment of up to 64 KB, at the very end.
        let lowest = max(0, archive.count - 22 - 0xFFFF)
        var offset = archive.count - 22
        while offset >= lowest {
            if archive.readLE(UInt32.self, at: offset) == 0x0605_4B50 { return offset }
            offset -= 1
        }
        return nil
    }

    /// Raw DEFLATE, which is what Apple's `COMPRESSION_ZLIB` decodes, streamed in chunks and stopped
    /// as soon as the output passes the size the archive declared: the declared size is never trusted
    /// to allocate, and a stream that keeps expanding is cut off.
    private static func inflate(_ data: Data, expectedSize: Int) throws(Failure) -> Data {
        let chunk = 64 * 1024
        var output = Data()
        let stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer { stream.deallocate() }
        guard compression_stream_init(stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB) == COMPRESSION_STATUS_OK else { throw .damaged }
        defer { compression_stream_destroy(stream) }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: chunk)
        defer { buffer.deallocate() }

        let failed: Bool = data.withUnsafeBytes { source in
            guard let base = source.bindMemory(to: UInt8.self).baseAddress else { return expectedSize != 0 }
            stream.pointee.src_ptr = base
            stream.pointee.src_size = data.count
            while true {
                stream.pointee.dst_ptr = buffer
                stream.pointee.dst_size = chunk
                let status = compression_stream_process(stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                let produced = chunk - stream.pointee.dst_size
                if output.count + produced > expectedSize { return true }
                output.append(buffer, count: produced)
                switch status {
                case COMPRESSION_STATUS_END: return false
                case COMPRESSION_STATUS_OK where produced > 0 || stream.pointee.src_size > 0: continue
                default: return true
                }
            }
        }
        guard !failed, output.count == expectedSize else { throw .damaged }
        return output
    }
}
