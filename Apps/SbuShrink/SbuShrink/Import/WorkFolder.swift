import Foundation

/// The app's scratch space in the temporary directory: imported videos and compressed copies
/// live here until the next batch, and the system may clear it any time the app is closed.
nonisolated enum WorkFolder {
    static var root: URL {
        URL.temporaryDirectory.appending(path: "Shrink", directoryHint: .isDirectory)
    }

    /// A new, empty folder for one file, so two videos with the same name never collide.
    static func newFolder() throws -> URL {
        let folder = root.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    /// Copies `file` into a new folder, keeping its name.
    static func copy(_ file: URL) throws -> URL {
        let destination = try newFolder().appending(path: file.lastPathComponent)
        try FileManager.default.copyItem(at: file, to: destination)
        return destination
    }

    /// `copy(_:)` off the main actor: a long video takes a while to copy.
    @concurrent
    static func copyInBackground(_ file: URL) async throws -> URL {
        try copy(file)
    }

    /// Where the compressed copy of `source` goes: the same name with the output's extension.
    static func output(for source: URL, format: OutputFormat) throws -> URL {
        let name = source.deletingPathExtension().lastPathComponent
        return try newFolder().appending(path: name.isEmpty ? "video" : name).appendingPathExtension(format.fileExtension)
    }

    /// Removes everything from earlier batches.
    static func clear() {
        try? FileManager.default.removeItem(at: root)
    }
}
