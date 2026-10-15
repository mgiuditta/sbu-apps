import Foundation

/// Reads and writes `TripLogFile` as JSON at one URL, atomically, as Sbu Habits does.
nonisolated struct TripLogStore: Sendable {
    enum Failure: Error, Equatable {
        /// The file was written by a newer version of the app: never read or overwrite it.
        case unknownVersion(Int)
    }

    /// The file in Application Support; a throwaway file for UI tests and screenshots.
    static var shared: TripLogStore {
        // UI tests run each case on its own throwaway file, named in the launch environment.
        if let name = ProcessInfo.processInfo.environment["SBU_SPEED_TRIPS_FILE"] {
            return TripLogStore(url: .temporaryDirectory.appending(path: name))
        }
        // fastlane snapshot shows demo trips, never the user's own.
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            let store = TripLogStore(url: .temporaryDirectory.appending(path: "snapshot-trips.json"))
            try? store.save(.demo(now: .now))
            return store
        }
        return TripLogStore(url: .applicationSupportDirectory.appending(path: "trips.json"))
    }

    let url: URL

    /// The saved file, or an empty one if nothing was saved yet.
    func load() throws -> TripLogFile {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return TripLogFile() }
        let data = try Data(contentsOf: url)
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= TripLogFile.currentVersion else { throw Failure.unknownVersion(version) }
        return try JSONDecoder().decode(TripLogFile.self, from: data)
    }

    func save(_ file: TripLogFile) throws {
        // A newer app may have written this file: overwriting it would lose trips we cannot read.
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Header.self, from: data),
           saved.version > TripLogFile.currentVersion {
            throw Failure.unknownVersion(saved.version)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
