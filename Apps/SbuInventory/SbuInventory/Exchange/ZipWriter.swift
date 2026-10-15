import Foundation

/// Writes a ZIP archive to a file one entry at a time, so hundreds of photos never sit in memory together.
///
/// Entries are stored, not compressed: the photos are HEIC, already compressed, and the CSV is small.
/// Names are UTF-8. Without ZIP64 an archive holds up to 65,535 entries and 4 GB.
nonisolated final class ZipWriter {
    enum Failure: Error {
        case tooLarge
    }

    private struct Entry {
        let name: Data
        let crc: UInt32
        let size: UInt32
        let offset: UInt32
    }

    private let handle: FileHandle
    private var entries: [Entry] = []
    private var offset: UInt64 = 0
    private let time: UInt16
    private let date: UInt16

    /// Creates the file at `url`, replacing any file there.
    init(url: URL, date: Date = .now, calendar: Calendar = .current) throws {
        FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil)
        handle = try FileHandle(forWritingTo: url)
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        time = UInt16((parts.hour ?? 0) << 11 | (parts.minute ?? 0) << 5 | (parts.second ?? 0) / 2)
        self.date = UInt16(max((parts.year ?? 1980) - 1980, 0) << 9 | (parts.month ?? 1) << 5 | (parts.day ?? 1))
    }

    func add(_ name: String, data: Data) throws {
        guard entries.count < 0xFFFF, offset + UInt64(data.count) + 1024 < 0xFFFF_FFFF else { throw Failure.tooLarge }
        let nameData = Data(name.utf8)
        let crc = CRC32.checksum(data)
        let size = UInt32(data.count)
        var header = Data()
        header.append(le: UInt32(0x0403_4B50))
        header.append(le: UInt16(20))       // version needed
        header.append(le: UInt16(0x0800))   // UTF-8 names
        header.append(le: UInt16(0))        // stored
        header.append(le: time)
        header.append(le: date)
        header.append(le: crc)
        header.append(le: size)
        header.append(le: size)
        header.append(le: UInt16(nameData.count))
        header.append(le: UInt16(0))
        header.append(nameData)
        try handle.write(contentsOf: header)
        try handle.write(contentsOf: data)
        entries.append(Entry(name: nameData, crc: crc, size: size, offset: UInt32(offset)))
        offset += UInt64(header.count + data.count)
    }

    /// Writes the central directory and closes the file.
    func finish() throws {
        var directory = Data()
        for entry in entries {
            directory.append(le: UInt32(0x0201_4B50))
            directory.append(le: UInt16(20))    // made by
            directory.append(le: UInt16(20))    // version needed
            directory.append(le: UInt16(0x0800))
            directory.append(le: UInt16(0))
            directory.append(le: time)
            directory.append(le: date)
            directory.append(le: entry.crc)
            directory.append(le: entry.size)
            directory.append(le: entry.size)
            directory.append(le: UInt16(entry.name.count))
            directory.append(le: UInt16(0))     // extra
            directory.append(le: UInt16(0))     // comment
            directory.append(le: UInt16(0))     // disk
            directory.append(le: UInt16(0))     // internal attributes
            directory.append(le: UInt32(0))     // external attributes
            directory.append(le: entry.offset)
            directory.append(entry.name)
        }
        guard offset + UInt64(directory.count) < 0xFFFF_FFFF else { throw Failure.tooLarge }
        var end = Data()
        end.append(le: UInt32(0x0605_4B50))
        end.append(le: UInt16(0))
        end.append(le: UInt16(0))
        end.append(le: UInt16(entries.count))
        end.append(le: UInt16(entries.count))
        end.append(le: UInt32(directory.count))
        end.append(le: UInt32(offset))
        end.append(le: UInt16(0))
        try handle.write(contentsOf: directory + end)
        try handle.close()
    }
}
