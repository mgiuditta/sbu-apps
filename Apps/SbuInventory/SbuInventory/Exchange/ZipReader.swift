import Compression
import Foundation

/// Reads the files of a ZIP archive: this app's own, stored, and the deflated ones Files or Finder make
/// when you zip a folder again. Every file is checked against its CRC.
nonisolated enum ZipReader {
    enum Failure: Error, Equatable {
        case notAZip
        case damaged
    }

    /// Every file in the archive by name; folders are left out.
    static func files(in archive: Data) throws(Failure) -> [String: Data] {
        guard let end = endOfCentralDirectory(in: archive),
              let count = archive.readLE(UInt16.self, at: end + 10),
              let directoryOffset = archive.readLE(UInt32.self, at: end + 16) else { throw .notAZip }
        var files: [String: Data] = [:]
        var cursor = Int(directoryOffset)
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
                  cursor + 46 + nameLength <= archive.count else { throw .damaged }
            let nameStart = archive.startIndex + cursor + 46
            let name = String(decoding: archive[nameStart..<nameStart + nameLength], as: UTF8.self)
            cursor += 46 + nameLength + extraLength + commentLength

            guard !name.hasSuffix("/") else { continue }
            guard archive.readLE(UInt32.self, at: localOffset) == 0x0403_4B50,
                  let localName = archive.readLE(UInt16.self, at: localOffset + 26).map(Int.init),
                  let localExtra = archive.readLE(UInt16.self, at: localOffset + 28).map(Int.init) else { throw .damaged }
            let dataStart = localOffset + 30 + localName + localExtra
            guard dataStart + compressedSize <= archive.count else { throw .damaged }
            let stored = archive[(archive.startIndex + dataStart)..<(archive.startIndex + dataStart + compressedSize)]
            let data: Data
            switch method {
            case 0: data = Data(stored)
            case 8: data = try inflate(Data(stored), size: size)
            default: continue
            }
            guard CRC32.checksum(data) == crc else { throw .damaged }
            files[name] = data
        }
        return files
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

    /// Raw DEFLATE, which is what Apple's `COMPRESSION_ZLIB` decodes.
    private static func inflate(_ data: Data, size: Int) throws(Failure) -> Data {
        guard size > 0 else { return Data() }
        var output = Data(count: size)
        let written = output.withUnsafeMutableBytes { destination in
            data.withUnsafeBytes { source in
                compression_decode_buffer(
                    destination.bindMemory(to: UInt8.self).baseAddress!, size,
                    source.bindMemory(to: UInt8.self).baseAddress!, data.count,
                    nil, COMPRESSION_ZLIB
                )
            }
        }
        guard written == size else { throw .damaged }
        return output
    }
}
