/// Why a ZIP archive could not be read.
nonisolated enum ZipError: Error, Equatable, Sendable {
    /// No end-of-central-directory record: not a ZIP, or cut short.
    case notAnArchive
    /// A record points outside the file, overflows, or has the wrong signature.
    case damaged
    /// Encrypted, or compressed with a method other than stored or DEFLATE.
    case unsupportedMethod
    /// The decompressed bytes don't match the CRC-32 the archive recorded.
    case checksumMismatch
    /// Too many entries, or an entry larger or more compressed than any chat: a ZIP bomb.
    case tooLarge
}
