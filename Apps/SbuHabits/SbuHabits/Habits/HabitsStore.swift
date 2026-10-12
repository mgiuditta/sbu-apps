import Foundation

/// Reads and writes `HabitsFile` as JSON at one URL, atomically.
nonisolated struct HabitsStore: Sendable {
    enum Failure: Error, Equatable {
        /// The file was written by a newer version of the app: never read or overwrite it.
        case unknownVersion(Int)
    }

    static let appGroup = "group.dev.sbu.habits"

    /// The file in the App Group container, or in Application Support if the group is missing.
    static var shared: HabitsStore {
        let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) ?? .applicationSupportDirectory
        return HabitsStore(url: folder.appending(path: "habits.json"))
    }

    let url: URL

    /// The saved file, or an empty one if nothing was saved yet.
    func load() throws -> HabitsFile {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return HabitsFile() }
        let data = try Data(contentsOf: url)
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= HabitsFile.currentVersion else { throw Failure.unknownVersion(version) }
        return try JSONDecoder().decode(HabitsFile.self, from: data)
    }

    func save(_ file: HabitsFile) throws {
        // A newer app may have written this file: overwriting it would lose data we cannot read.
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Header.self, from: data),
           saved.version > HabitsFile.currentVersion {
            throw Failure.unknownVersion(saved.version)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
