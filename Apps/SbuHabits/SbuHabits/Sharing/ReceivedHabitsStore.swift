import Foundation

/// Reads and writes `ReceivedHabitsFile` as JSON at one URL, atomically.
nonisolated struct ReceivedHabitsStore: Sendable {
    enum Failure: Error, Equatable {
        /// Written by a newer version of the app: never read or overwrite it.
        case unknownVersion(Int)
    }

    /// The file in the App Group container, next to `habits.json` but apart from it. UI tests
    /// name a throwaway file with `SBU_HABITS_SHARED_FILE`; screenshots never show one.
    static var shared: ReceivedHabitsStore {
        if let name = ProcessInfo.processInfo.environment["SBU_HABITS_SHARED_FILE"] {
            return ReceivedHabitsStore(url: .temporaryDirectory.appending(path: name))
        }
        if ProcessInfo.processInfo.environment["SBU_HABITS_FILE"] != nil || UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            return ReceivedHabitsStore(url: .temporaryDirectory.appending(path: "received-\(UUID().uuidString).json"))
        }
        let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: HabitsStore.appGroup) ?? .applicationSupportDirectory
        return ReceivedHabitsStore(url: folder.appending(path: "received-habits.json"))
    }

    let url: URL

    /// The saved file, or an empty one if nothing was received yet.
    func load() throws -> ReceivedHabitsFile {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return ReceivedHabitsFile() }
        let data = try Data(contentsOf: url)
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= ReceivedHabitsFile.currentVersion else { throw Failure.unknownVersion(version) }
        return try JSONDecoder().decode(ReceivedHabitsFile.self, from: data)
    }

    func save(_ file: ReceivedHabitsFile) throws {
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Header.self, from: data),
           saved.version > ReceivedHabitsFile.currentVersion {
            throw Failure.unknownVersion(saved.version)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
