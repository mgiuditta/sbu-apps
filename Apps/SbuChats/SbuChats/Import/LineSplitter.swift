import Foundation

/// Turns UTF-8 chunks into lines, keeping only the unfinished line between chunks.
///
/// Splits on `\n` and drops a trailing `\r`, so iPhone (CRLF) and Android (LF) exports read the
/// same. A byte order mark at the start is skipped. Invalid UTF-8 is repaired, never fatal.
nonisolated struct LineSplitter {
    private var pending: [UInt8] = []
    private var isAtStart = true

    /// Feeds the next chunk and calls `line` for each complete line in it.
    mutating func feed(_ chunk: Data, line: (String) throws -> Void) rethrows {
        var bytes = [UInt8](chunk)
        if isAtStart, !bytes.isEmpty || !pending.isEmpty {
            let joined = pending + bytes
            if joined.count < 3, [0xEF, 0xBB, 0xBF].starts(with: joined) {
                pending = joined
                return
            }
            pending = []
            bytes = joined.starts(with: [0xEF, 0xBB, 0xBF]) ? Array(joined.dropFirst(3)) : joined
            isAtStart = false
        }
        var start = 0
        for index in bytes.indices where bytes[index] == 0x0A {
            if pending.isEmpty {
                try line(Self.decode(bytes[start ..< index]))
            } else {
                pending.append(contentsOf: bytes[start ..< index])
                try line(Self.decode(pending[...]))
                pending.removeAll(keepingCapacity: true)
            }
            start = index + 1
        }
        pending.append(contentsOf: bytes[start...])
    }

    /// Calls `line` with the last line when the text doesn't end with a newline.
    mutating func finish(line: (String) throws -> Void) rethrows {
        if !pending.isEmpty {
            try line(Self.decode(pending[...]))
            pending = []
        }
    }

    private static func decode(_ bytes: ArraySlice<UInt8>) -> String {
        var slice = bytes
        if slice.last == 0x0D { slice = slice.dropLast() }
        return String(decoding: slice, as: UTF8.self)
    }
}
