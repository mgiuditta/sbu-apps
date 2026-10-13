import Foundation

/// A value saved as one file in the app's Application Support folder.
///
/// JSON for small state the user makes; a binary property list for big caches, which reads
/// and writes much faster.
nonisolated struct StoredFile<Value: Codable & Sendable>: Sendable {
    nonisolated enum Format: Sendable {
        case json
        case binary
    }

    let url: URL
    let format: Format

    /// A file in Application Support/Sbu Clean, or in `directory` for tests.
    init(name: String, format: Format = .json, directory: URL? = nil) {
        let folder = directory ?? URL.applicationSupportDirectory.appending(path: "SbuClean", directoryHint: .isDirectory)
        url = folder.appending(path: name)
        self.format = format
    }

    /// The saved value; `nil` when there is none or it cannot be read.
    func load() -> Value? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        switch format {
        case .json: return try? JSONDecoder().decode(Value.self, from: data)
        case .binary: return try? PropertyListDecoder().decode(Value.self, from: data)
        }
    }

    /// Writes the value atomically, creating the folder the first time.
    func save(_ value: Value) throws {
        let data: Data
        switch format {
        case .json:
            data = try JSONEncoder().encode(value)
        case .binary:
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            data = try encoder.encode(value)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    /// Removes the file, if any.
    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
