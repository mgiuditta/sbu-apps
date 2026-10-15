import Foundation

/// Turns UTF-8 chunks into lines, keeping only the unfinished line between chunks.
///
/// Splits on LF, CRLF and a lone CR, so iPhone, Android and old Mac files read the same. A byte
/// order mark at the start is skipped. Invalid UTF-8 is repaired, never fatal. A line longer than
/// `maximumLineBytes` stops the import with `ImportFailure.lineTooLong`: a file without line
/// breaks never grows the buffer past the ceiling.
nonisolated struct LineSplitter {
    /// WhatsApp caps a message at 65,536 characters, at most 256 KB of UTF-8: 1 MB is never a chat line.
    static let defaultMaximumLineBytes = 1024 * 1024

    let maximumLineBytes: Int
    private var pending: [UInt8] = []
    private var isFirstLine = true
    /// A CR ended the last line: an LF right after it belongs to the same break.
    private var skipsLineFeed = false

    init(maximumLineBytes: Int = Self.defaultMaximumLineBytes) {
        self.maximumLineBytes = maximumLineBytes
    }

    /// Feeds the next chunk and calls `line` for each complete line in it.
    mutating func feed(_ chunk: Data, line: (String) throws -> Void) throws {
        for byte in chunk {
            if skipsLineFeed {
                skipsLineFeed = false
                if byte == 0x0A { continue }
            }
            switch byte {
            case 0x0A, 0x0D:
                try line(takeLine())
                skipsLineFeed = byte == 0x0D
            default:
                guard pending.count < maximumLineBytes else { throw ImportFailure.lineTooLong }
                pending.append(byte)
            }
        }
    }

    /// Calls `line` with the last line when the text doesn't end with a line break.
    mutating func finish(line: (String) throws -> Void) rethrows {
        if !pending.isEmpty {
            try line(takeLine())
        }
    }

    private mutating func takeLine() -> String {
        defer {
            pending.removeAll(keepingCapacity: true)
            isFirstLine = false
        }
        var bytes = pending[...]
        if isFirstLine, bytes.starts(with: [0xEF, 0xBB, 0xBF]) { bytes = bytes.dropFirst(3) }
        return String(decoding: bytes, as: UTF8.self)
    }
}
