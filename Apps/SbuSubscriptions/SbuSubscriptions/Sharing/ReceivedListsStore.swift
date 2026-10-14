import Foundation

/// Reads and writes `ReceivedListsFile` as JSON, atomically, in the App Group container.
nonisolated struct ReceivedListsStore: Sendable {
    enum Failure: Error, Equatable {
        /// Written by a newer version of the app: never read or overwrite it.
        case unknownVersion(Int)
    }

    let url: URL

    static var shared: ReceivedListsStore {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE") {
            return ReceivedListsStore(url: .temporaryDirectory.appending(path: "received-\(UUID().uuidString).json"))
        }
        let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.sbu.subscriptions") ?? .applicationSupportDirectory
        return ReceivedListsStore(url: folder.appending(path: "received-lists.json"))
    }

    func load() throws -> ReceivedListsFile {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return ReceivedListsFile() }
        let data = try Data(contentsOf: url)
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= ReceivedListsFile.currentVersion else { throw Failure.unknownVersion(version) }
        return try JSONDecoder().decode(ReceivedListsFile.self, from: data)
    }

    func save(_ file: ReceivedListsFile) throws {
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Header.self, from: data),
           saved.version > ReceivedListsFile.currentVersion {
            throw Failure.unknownVersion(saved.version)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
