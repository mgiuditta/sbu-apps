import Foundation

/// Reads and writes `NoiseFile` as JSON at one URL, atomically.
nonisolated struct NoiseStore: Sendable {
    enum Failure: Error, Equatable {
        /// The file was written by a newer version of the app: never read or overwrite it.
        case unknownVersion(Int)
    }

    /// The file in the App Group container, where Comandi rapidi read the mixes.
    static var shared: NoiseStore {
        // UI tests run each case on its own throwaway file, named in the launch environment.
        if let name = ProcessInfo.processInfo.environment["SBU_NOISE_FILE"] {
            return NoiseStore(url: .temporaryDirectory.appending(path: name))
        }
        return NoiseStore(url: AppGroup.folder.appending(path: "noise.json"))
    }

    let url: URL

    /// The saved file, or an empty one if nothing was saved yet.
    func load() throws -> NoiseFile {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return NoiseFile() }
        let data = try Data(contentsOf: url)
        let version = try JSONDecoder().decode(Header.self, from: data).version
        guard version <= NoiseFile.currentVersion else { throw Failure.unknownVersion(version) }
        return try JSONDecoder().decode(NoiseFile.self, from: data)
    }

    func save(_ file: NoiseFile) throws {
        // A newer app may have written this file: overwriting it would lose data we cannot read.
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Header.self, from: data),
           saved.version > NoiseFile.currentVersion {
            throw Failure.unknownVersion(saved.version)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(file).write(to: url, options: .atomic)
    }

    /// Reads, changes and writes the file in one go, so each model writes only its own part.
    func update(_ change: (inout NoiseFile) -> Void) throws {
        var file = try load()
        change(&file)
        try save(file)
    }

    private struct Header: Decodable {
        let version: Int
    }
}
