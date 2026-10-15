import Foundation

/// One file in a ZIP archive, as its central directory describes it.
nonisolated struct ZipEntry: Equatable, Sendable {
    /// How the bytes are stored.
    enum Method: Equatable, Sendable {
        /// Method 0: the bytes as they are.
        case stored
        /// Method 8: raw DEFLATE.
        case deflated
        /// Any other method, which the reader does not decompress.
        case unsupported(UInt16)
    }

    /// The path inside the archive, with `/` between folders.
    let path: String
    let method: Method
    let crc32: UInt32
    let compressedSize: UInt64
    let uncompressedSize: UInt64
    /// Where the entry's local header starts in the archive file.
    let localHeaderOffset: UInt64

    /// The last path component.
    var fileName: String {
        path.split(separator: "/").last.map(String.init) ?? path
    }

    /// A folder entry, or macOS's resource-fork copies under `__MACOSX/`: never a chat.
    var isMetadata: Bool {
        path.hasSuffix("/") || path.hasPrefix("__MACOSX/") || fileName.hasPrefix("._")
    }
}
