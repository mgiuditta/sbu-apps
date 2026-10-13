import Foundation

/// The copy of `habits.json` in the app's iCloud container, at its root and not in Documents, so
/// it never shows in the Files app or in iCloud Drive. It goes only to the user's own iCloud.
///
/// Every call runs off the main actor: finding the container and coordinated reads and writes can
/// wait on iCloud. The coordinator calls back on its own queue, never blocking a Swift thread.
nonisolated struct ICloudHabitsFile: HabitsRemote {
    static let containerIdentifier = "iCloud.dev.sbu.habits"
    static let fileName = "habits.json"

    enum Failure: Error {
        /// iCloud Drive is off, or the app has no container.
        case noContainer
    }

    @concurrent
    func read() async throws -> RemoteRead {
        let url = try Self.url()
        let manager = FileManager.default
        let status = try? url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]).ubiquitousItemDownloadingStatus
        let placeholder = url.deletingLastPathComponent().appending(path: ".\(Self.fileName).icloud")
        let isLocal = manager.fileExists(atPath: url.path(percentEncoded: false))
        guard isLocal || status != nil || manager.fileExists(atPath: placeholder.path(percentEncoded: false)) else {
            return .missing
        }
        if let status, status != .current {
            // The metadata query says when it is here; reading now would wait on the network.
            try manager.startDownloadingUbiquitousItem(at: url)
            return .downloading
        }
        if isLocal == false {
            try manager.startDownloadingUbiquitousItem(at: url)
            return .downloading
        }
        return try await Self.coordinate(.readingIntent(with: url), at: url) { url in
            let data = try Data(contentsOf: url)
            let conflicts = (NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? []).compactMap { version in
                (try? Data(contentsOf: version.url)).map { RemoteConflict(url: version.url, data: $0) }
            }
            return .found(data, conflicts: conflicts)
        }
    }

    @concurrent
    func write(_ data: Data, resolving conflicts: [RemoteConflict]) async throws {
        let url = try Self.url()
        let resolved = Set(conflicts.map(\.url))
        try await Self.coordinate(.writingIntent(with: url, options: .forReplacing), at: url) { url in
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
            let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? []
            for version in versions where resolved.contains(version.url) {
                version.isResolved = true
            }
            // Only once every conflict is merged: one that came meanwhile waits for the next sync.
            if versions.allSatisfy(\.isResolved) {
                try? NSFileVersion.removeOtherVersionsOfItem(at: url)
            }
        }
    }

    /// The file in the container. Can take a while the first time: never on the main actor.
    private static func url() throws -> URL {
        guard let container = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
            throw Failure.noContainer
        }
        return container.appending(path: fileName)
    }

    /// Serial, so this app's own reads and writes never overlap.
    private static let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .utility
        return queue
    }()

    /// Runs `body` under file coordination, so iCloud never reads or replaces the file halfway.
    private static func coordinate<Result: Sendable>(_ intent: NSFileAccessIntent, at url: URL, _ body: @escaping @Sendable (URL) throws -> Result) async throws -> Result {
        try await withCheckedThrowingContinuation { continuation in
            NSFileCoordinator(filePresenter: nil).coordinate(with: [intent], queue: queue) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(with: Swift.Result { try body(url) })
                }
            }
        }
    }
}
