import Foundation

/// The Vision analyses on disk, in chunks, so a scan of tens of thousands of photos only ever
/// writes what is new: each save adds one small file; the next launch reads them all.
nonisolated struct AnalysisStore: Sendable {
    /// Past this many chunks, the next compaction merges them into one.
    static let compactAfter = 40

    let folder: URL

    /// The store in Application Support/SbuClean/analyses, or in `directory` for tests.
    init(directory: URL? = nil) {
        let base = directory ?? URL.applicationSupportDirectory.appending(path: "SbuClean", directoryHint: .isDirectory)
        folder = base.appending(path: "analyses", directoryHint: .isDirectory)
    }

    /// Every analysis saved so far.
    @concurrent
    func load() async -> [String: ImageAnalysis] {
        var all: [String: ImageAnalysis] = [:]
        for url in chunks() {
            guard let data = try? Data(contentsOf: url),
                  let chunk = try? PropertyListDecoder().decode([String: ImageAnalysis].self, from: data) else { continue }

            all.merge(chunk) { _, new in new }
        }
        return all
    }

    /// Saves new analyses as one more chunk.
    @concurrent
    func append(_ analyses: [String: ImageAnalysis]) async {
        guard !analyses.isEmpty else { return }

        write(analyses, name: "chunk-\(UUID().uuidString).plist")
    }

    /// Rewrites everything still useful as one chunk when there are many; keeps only `keep`.
    @concurrent
    func compact(_ analyses: [String: ImageAnalysis], keep: Set<String>) async {
        let existing = chunks()
        guard existing.count > Self.compactAfter else { return }

        let kept = analyses.filter { keep.contains($0.key) }
        guard write(kept, name: "chunk-\(UUID().uuidString).plist") else { return }

        for url in existing {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func chunks() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        return urls.filter { $0.pathExtension == "plist" }
    }

    @discardableResult
    private func write(_ analyses: [String: ImageAnalysis], name: String) -> Bool {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        guard let data = try? encoder.encode(analyses) else { return false }

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try data.write(to: folder.appending(path: name), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            return true
        } catch {
            return false
        }
    }
}
