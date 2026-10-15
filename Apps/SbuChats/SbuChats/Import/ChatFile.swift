import Foundation

/// A file the user shared or picked, opened as a chat export: its text, name and whether it has media.
nonisolated struct ChatFile {
    let source: ChatTextSource
    /// The chat's name from the file name, or `nil` when the file doesn't say.
    let title: String?
    /// Whether a `.zip` came with photos, videos or other files beside the text.
    let hasMedia: Bool

    /// Opens `url` as a `.zip` (by extension or by its first bytes) or as a `.txt`.
    init(url: URL) throws(ImportFailure) {
        let fileExtension = url.pathExtension.lowercased()
        if fileExtension == "zip" || Self.startsLikeZip(url) {
            let archive: ZipArchive
            do {
                archive = try ZipArchive(url: url)
            } catch {
                throw .damagedArchive
            }
            let files = archive.entries.filter { !$0.isMetadata }
            let texts = files.filter { $0.fileName.lowercased().hasSuffix(".txt") }
            // iPhone: `_chat.txt`; Android: "WhatsApp Chat with Anna.txt". Otherwise the biggest text.
            guard let chat = texts.first(where: { $0.fileName == "_chat.txt" }) ?? texts.max(by: { $0.uncompressedSize < $1.uncompressedSize }) else {
                throw .noChatInArchive
            }
            // Encrypted, or compressed in a way only desktop archivers use.
            if case .unsupported = chat.method { throw .damagedArchive }
            source = ChatTextSource(archive: archive, entry: chat)
            title = ChatTitle.title(fromFileName: url.lastPathComponent) ?? ChatTitle.title(fromFileName: chat.fileName)
            hasMedia = files.count > texts.count
        } else if ["txt", "text", ""].contains(fileExtension) {
            source = try ChatTextSource(textFile: url)
            title = ChatTitle.title(fromFileName: url.lastPathComponent)
            hasMedia = false
        } else {
            throw .unsupportedFile(fileExtension: fileExtension)
        }
    }

    private static func startsLikeZip(_ url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        return (try? handle.read(upToCount: 4)) == Data([0x50, 0x4B, 0x03, 0x04])
    }
}
